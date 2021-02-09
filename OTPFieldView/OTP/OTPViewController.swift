//
//  OTPViewController.swift
//  OTPFieldView
//
//  Created by Michael Sidoruk on 09.02.2021.
//

import UIKit
import SnapKit

class OTPViewController: UIViewController {
	
	private lazy var customView: OTPView = {
		let view = OTPView()
		view.delegate = self
		return view
	}()
	
	override func loadView() {
		view = customView
	}
}

extension OTPViewController: OTPViewDelegate {
	func otpFieldView(_ otpFieldView: OTPFieldView, didFillOtpCode otpCode: String?) {
		print(#function, ": \(otpCode)")
		print("Network request start")
		//quick mock
		customView.activityIndicatorView.startAnimating()
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
			self.customView.activityIndicatorView.stopAnimating()
			if Int.random(in: 0...10) >= 5 {
				print("Success")
				self.customView.update(state: .normal)
			} else {
				print("Failure")
				self.customView.update(state: .error)
			}
			print("Network request end")
		}
	}
	
	func otpFieldView(_ otpFieldView: OTPFieldView, otpCodeChanged char: String, at index: Int) {
		print(#function,": \(char) at \(index)")
		customView.update(state: .normal)
	}
}
