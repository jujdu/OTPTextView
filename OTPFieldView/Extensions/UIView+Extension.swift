//
//  UIView+Extension.swift
//  OTPFieldView
//
//  Created by Michael Sidoruk on 09.02.2021.
//

import UIKit

public extension UIView {
	func fadeTransion(_ duration: Double = 0.4) {
		let transition = CATransition()
		transition.duration = duration
		transition.type = .fade
		layer.add(transition, forKey: "fadeAnimation")
	}
	
	func fadeIn(_ duration: Double = 0.35, completion: (() -> Void)? = nil) {
		UIView.animate(withDuration: duration, delay: 0, options: .beginFromCurrentState, animations: {
			self.alpha = 1
		}, completion: { isFinished in
			if isFinished {
				completion?()
			}
		})
	}
	
	func fadeOut(_ duration: Double = 0.35, completion: (() -> Void)? = nil) {
		UIView.animate(withDuration: duration, delay: 0, options: .beginFromCurrentState, animations: {
			self.alpha = 0
		}, completion: { isFinished in
			if isFinished {
				completion?()
			}
		})
	}
}
