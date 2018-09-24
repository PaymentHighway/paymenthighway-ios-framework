//
//  AppDelegate.swift
//  PaymentHighwayDemo
//
//  Created by Nico Hämäläinen on 01/04/15.
//  Copyright (c) 2015 Payment Highway Oy. All rights reserved.
//

import UIKit
import PaymentHighway

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Environment.current = .sandbox
        let rootVC = MainViewController()
        let navController = UINavigationController(rootViewController: rootVC)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navController
        window.makeKeyAndVisible()
        self.window = window
		return true
	}

}
