//
//  OTPTextField.swift
//  OTPFieldView
//
//  Created by Michael Sidoruk on 09.02.2021.
//

import UIKit

public extension OTPTextField {
	struct Appearance {
		let cornerRadius: CGFloat = 8
		let textColor = UIColor.white
		let font = UIFont.systemFont(ofSize: 22)
		
		//should all refactoring for a covenience using. Just have removed all projects references
		let normalBackgroundColor = UIColor.white.withAlphaComponent(0.16)
		let errorBackgroundColor = #colorLiteral(red: 1, green: 0.1470200419, blue: 0.09345766157, alpha: 1).withAlphaComponent(0.16)
		let borderWidth: CGFloat = 0
		
		let selectedBorderWidth: CGFloat = 2
		
		let selectedNormalBackgroundColor = UIColor.white.withAlphaComponent(0.08)
		let selectedNormalBorderColor = UIColor.white.withAlphaComponent(0.38).cgColor
		
		let selectedErrorBackgroundColor = #colorLiteral(red: 1, green: 0.1470200419, blue: 0.09345766157, alpha: 1).withAlphaComponent(0.08)
		let selectedErrorBorderColor = #colorLiteral(red: 1, green: 0.1470200419, blue: 0.09345766157, alpha: 1).cgColor
		let fadeDuration: Double = 0.15
	}
}

public final class OTPTextField: UITextField {
	
	private let appearance: Appearance
	
	//MARK: - Public Properties
	
	public var otpState: OTPFieldView.State = .normal
		
	public override var isSelected: Bool {
		didSet {
			update(state: otpState)
		}
	}
	
	public override var selectedTextRange: UITextRange? {
		didSet {
			super.selectedTextRange = textRange(from: endOfDocument, to: endOfDocument)
		}
	}
	
	//MARK: - Inits
	
	init(appearance: Appearance = Appearance()) {
		self.appearance = appearance
		super.init(frame: .zero)
		self.translatesAutoresizingMaskIntoConstraints = false
		setupView()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	//MARK: - Overriden Methods
	
	public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		if gestureRecognizer is UILongPressGestureRecognizer {
			return false
		}
		return true
	}
	
	public override func deleteBackward() {
		super.deleteBackward()
		if text?.count == 0 {
			text = " "
			_ = delegate?.textField?(self, shouldChangeCharactersIn: NSRange(), replacementString: "")
		}
	}
	
	public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
		return false
	}
	
	//MARK: - Private Methods
	
	private func setupView() {
		if #available(iOS 12.0, *) {
			textContentType = .oneTimeCode
		}
		keyboardType = .numberPad
		contentVerticalAlignment = .center
		contentHorizontalAlignment = .center
		textAlignment = .center
	}
	
	//MARK: - Public Methods
	
	public func update(state: OTPFieldView.State) {
		otpState = state
		layer.cornerRadius = appearance.cornerRadius
		clipsToBounds = true
		textColor = appearance.textColor
		font = appearance.font
		
		switch state {
		case .normal where isSelected:
			backgroundColor = appearance.selectedNormalBackgroundColor
			layer.borderColor = appearance.selectedNormalBorderColor
			layer.borderWidth = appearance.selectedBorderWidth
		case .normal:
			backgroundColor = appearance.normalBackgroundColor
			layer.borderWidth = appearance.borderWidth
		case .error where isSelected:
			backgroundColor = appearance.selectedErrorBackgroundColor
			layer.borderColor = appearance.selectedErrorBorderColor
			layer.borderWidth = appearance.selectedBorderWidth
		case .error:
			backgroundColor = appearance.errorBackgroundColor
			layer.borderWidth = appearance.borderWidth
		}
		fadeTransion(appearance.fadeDuration)
	}
}
