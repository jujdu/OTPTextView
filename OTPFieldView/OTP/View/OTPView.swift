//
//  OTPView.swift
//  OTPFieldView
//
//  Created by Michael Sidoruk on 09.02.2021.
//

import UIKit

public protocol OTPViewDelegate: OTPFieldViewDelegate {}

final public class OTPView: UIView {
	
	public let activityIndicatorView: UIActivityIndicatorView = {
		let activityIndicatorView = UIActivityIndicatorView()
		activityIndicatorView.hidesWhenStopped = true
		activityIndicatorView.style = .large
		activityIndicatorView.color = .gray
		activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
		return activityIndicatorView
	}()
	
	private let otpFieldView: OTPFieldView = {
		let view = OTPFieldView()
		view.numberOfFields = 4
		view.minimumSpacing = 8
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	public var delegate: OTPViewDelegate? {
		didSet {
			otpFieldView.delegate = delegate
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = #colorLiteral(red: 0.1205684915, green: 0.1205962673, blue: 0.1205648109, alpha: 1)
		setupSubviews()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupSubviews() {
		addSubview(otpFieldView)
		addSubview(activityIndicatorView)
		
		otpFieldView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor).isActive = true
		otpFieldView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		otpFieldView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		otpFieldView.widthAnchor.constraint(equalToConstant: 345).isActive = true
		otpFieldView.heightAnchor.constraint(equalToConstant: 56).isActive = true
		
		activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 60).isActive = true
		activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		
	}
	
	public func update(state: OTPFieldView.State) {
		otpFieldView.update(with: state)
	}
}
