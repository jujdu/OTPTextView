//
//  AppDelegate.swift
//  OTPFieldView
//
//  Created by Michael Sidoruk on 09.02.2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
		window = UIWindow(frame: UIScreen.main.bounds)
		let rootVC = OTPViewController()
		window?.rootViewController = rootVC
		window?.makeKeyAndVisible()
		
		return true
	}
}
