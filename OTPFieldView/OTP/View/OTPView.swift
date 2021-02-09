//
//  OTPView.swift
//  OTPFieldView
//
//  Created by Michael Sidoruk on 09.02.2021.
//

import UIKit
import SnapKit

public protocol OTPViewDelegate: OTPFieldViewDelegate {}

final public class OTPView: UIView {
	
	public let activityIndicatorView: UIActivityIndicatorView = {
		let activityIndicatorView = UIActivityIndicatorView()
		activityIndicatorView.hidesWhenStopped = true
		activityIndicatorView.style = .large
		activityIndicatorView.color = .gray
		return activityIndicatorView
	}()
	
	private let otpFieldView: OTPFieldView = {
		let view = OTPFieldView()
		view.numberOfFields = 4
		view.minimumSpacing = 8
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
		
		otpFieldView.snp.makeConstraints { make in
			make.left.greaterThanOrEqualToSuperview()
			make.right.lessThanOrEqualToSuperview()
			make.center.equalToSuperview()
			make.size.equalTo(CGSize(width: 345, height: 56))
		}
		
		activityIndicatorView.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.centerY.equalToSuperview().offset(60)
		}
	}
	
	public func update(state: OTPFieldView.State) {
		otpFieldView.update(with: state)
	}
}
