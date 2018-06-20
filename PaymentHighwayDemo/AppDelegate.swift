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
        let accountId = "test"
        let merchantId = "test_merchantId"
        
        SPH.initSharedInstance(
            merchantId: merchantId,
            accountId: accountId,
            serverType: StagingServer.self
        )
        SPHTextField.appearance().backgroundColor = UIColor.red
		
		return true
	}

}
