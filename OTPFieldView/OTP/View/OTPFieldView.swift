//
//  OTPFieldView.swift
//  OTPFieldView
//
//  Created by Michael Sidoruk on 09.02.2021.
//

import UIKit

public protocol OTPFieldViewProtocol {
	var delegate: OTPFieldViewDelegate? { get set }
	var otpCode: String? { get set }
	var isFilled: Bool { get }
	var shouldHideIfFilled: Bool { get set }
	var numberOfFields: Int? { get set }
	var minimumSpacing: CGFloat { get set }
	var state: OTPFieldView.State { get }
	func update(with state: OTPFieldView.State)
	func reset(isActive: Bool)
	func reload()
}

public protocol OTPFieldViewDelegate: class {
	func otpFieldView(_ otpFieldView: OTPFieldView, didFillOtpCode otpCode: String?)
	func otpFieldView(_ otpFieldView: OTPFieldView, otpCodeChanged char: String, at index: Int)
}

public final class OTPFieldView: UIView, OTPFieldViewProtocol {
	
	public enum State {
		case normal
		case error
	}
	
	//MARK: - Views
	
	private lazy var stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.alignment = .fill
		stackView.distribution = .fillEqually
		stackView.spacing = minimumSpacing
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()
	
	private var textFields: [OTPTextField]? {
		stackView.arrangedSubviews as? [OTPTextField]
	}
	
	//MARK: - Private Properties
	
	private var currentIndex: Int? {
		willSet {
			handleSelectedFields(previousIndex: currentIndex, nextIndex: newValue)
		}
	}
	
	private var maxIndex: Int {
		guard let numberOfFields = numberOfFields else { return 0 }
		return max(0, numberOfFields - 1)
	}
	
	private var nextIndex: Int {
		guard let numberOfFields = numberOfFields, let currentIndex = currentIndex else { return 0 }
		return min(numberOfFields - 1, currentIndex + 1)
	}
	
	private var previousIndex: Int {
		guard let currentIndex = currentIndex else { return 0 }
		return max(0, currentIndex - 1)
	}
	
	private var isAutoFilled: Bool = false
	
	//MARK: - Public Properties
	
	public var delegate: OTPFieldViewDelegate?
	
	public var state: OTPFieldView.State = .normal {
		didSet {
			update(with: state)
		}
	}
	
	public var isFilled: Bool {
		guard let numberOfFields = numberOfFields else { fatalError("[OTPFieldView]: set numberOfFields") }
		return otpCode?.count == numberOfFields ? true : false
	}
	
	public var shouldHideIfFilled: Bool = true
	
	public var numberOfFields: Int?
	
	public var minimumSpacing: CGFloat = 0 {
		willSet {
			guard newValue != stackView.spacing else { return }
			stackView.spacing = newValue
		}
	}
	
	public var otpCode: String? {
		get {
			guard let otpCodeChars = textFields?.compactMap({ $0.text }), otpCodeChars.count == numberOfFields else {
				return nil
			}
			return otpCodeChars.reduce("", +)
		}
		set {
			guard let otpCode = newValue, !otpCode.isEmpty else {
				textFields?.forEach { $0.text = "" }
				return
			}
			guard let numberOfFields = numberOfFields else { return }
			for (index, char) in otpCode.prefix(numberOfFields).enumerated() {
				textFields?[index].text = String(char)
			}
			endEditing(true)
		}
	}
	
	//MARK: - Inits
	
	init() {
		super.init(frame: .zero)
		setupSubviews()
		setupConstraints()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	//MARK: - Overriden Methods
	
	public override func willMove(toSuperview newSuperview: UIView?) {
		setupView()
	}
	
	//MARK: - Private Methods
	
	private func setupView() {
		setupFields()
		state = .normal
	}
	
	private func setupSubviews() {
		addSubview(stackView)
	}
	
	private func setupConstraints() {
		stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
	}
	
	private func setupFields() {
		textFields?.forEach { $0.removeFromSuperview() }
		guard let numberOfFields = numberOfFields else { fatalError("[OTPFieldView]: set numberOfFields") }
		for _ in 1...numberOfFields {
			let textField = OTPTextField()
			textField.delegate = self
			stackView.addArrangedSubview(textField)
		}
	}
	
	private func handleSelectedFields(previousIndex: Int?, nextIndex: Int?) {
		guard let nextIndex = nextIndex else {
			textFields?.forEach{ $0.isSelected = false }
			return
		}
		if let previousIndex = previousIndex {
			textFields?[previousIndex].isSelected = false
		}
		if !isAutoFilled {
			textFields?[nextIndex].isSelected = true
		}
	}
	
	private func setNextTextFieldActiveIfNeeded() {
		if !isFilled {
			setTextFieldActive(at: nextIndex)
		} else {
			setTextFieldActive(at: nil)
		}
	}
	
	private func setPreviousTextFieldActiveIfNeeded() {
		setTextFieldActive(at: previousIndex)
	}
	
	private func setTextFieldActive(at index: Int?) {
		currentIndex = index
		if isFilled && shouldHideIfFilled {
			endEditing(true)
		} else if let index = index {
			textFields?[index].becomeFirstResponder()
		}
	}
	
	//MARK: - Public Methods
	
	public func update(with state: State) {
		textFields?.forEach{ $0.update(state: state) }
	}
	
	///reset current state to normal with empty fields
	public func reset(isActive: Bool = true) {
		state = .normal
		textFields?.forEach{ $0.text = "" }
		isAutoFilled = false
		if isActive {
			setTextFieldActive(at: 0)
		}
	}
	
	///for rebuild field after numberOfFields is changed
	public func reload() {
		setupView()
		isAutoFilled = false
	}
}

//MARK: - UITextFieldDelegate Implementation

extension OTPFieldView: UITextFieldDelegate {
	
	private enum Action {
		case sms
		case write
		case rewrite
		case delete
	}
	
	private func getAction(currentText: String, replacementText: String) -> Action? {
		//UITextContentType.oneTimeCode mode works only with empty textField and here we always get "" string for the firstResponder.
		if currentText.isEmpty && replacementText.isEmpty && !isAutoFilled {
			return .sms
		} else if currentText.isEmpty && !replacementText.isEmpty {
			return .write
		} else if !currentText.isEmpty && !replacementText.isEmpty {
			return .rewrite
		} else if replacementText.isEmpty {
			return .delete
		}
		return nil
	}
	
	public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		guard let currentText = textField.text,
			  CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string))
		else { return false }
		
		delegate?.otpFieldView(self, otpCodeChanged: string, at: currentIndex ?? 0)
		
		let action = getAction(currentText: currentText, replacementText: string)
		switch action {
		case .sms:
			//iOS checks any textFields with oneTimeCode mode on the whole view or superview(idk),
			//separates chars and paste each one to these textFields by itself. The selected field will be the firstResponder,
			//that's why we need to change firstResponder to first textField if a user selects a field which has index > 0.
			//isAutoFilled is needed to not call setTextFieldActive for "numberOfFields" times and not set the firstResponder as selected.
			isAutoFilled = true
			setTextFieldActive(at: 0)
		case .write, .rewrite:
			textField.text = string
			setNextTextFieldActiveIfNeeded()
		case .delete:
			textField.text = ""
			setPreviousTextFieldActiveIfNeeded()
		default:
			return false
		}
		
		if isFilled {
			delegate?.otpFieldView(self, didFillOtpCode: otpCode)
			isAutoFilled = false
		}
		
		return false
	}
	
	public func textFieldDidBeginEditing(_ textField: UITextField) {
		let index = textFields?.firstIndex(where: { $0 == textField })
		if index != currentIndex {
			currentIndex = index
		}
	}
	
	public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		textField.isUserInteractionEnabled = false
		return true
	}
	
	public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
		textField.isUserInteractionEnabled = true
		return true
	}
}
