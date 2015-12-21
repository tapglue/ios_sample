//
//  AppDelegate.swift
//  TapglueSample
//
//  Created by Onur Akpolat on 23.10.15.
//  Copyright © 2015 Tapglue. All rights reserved.
//

import UIKit
import Tapglue

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Black tintColor to change appearence of tabBar image color
//        UITabBar.appearance().tintColor = UIColor(red:0.23, green:0.23, blue:0.23, alpha:1.0)
        
        let config = TGConfiguration.defaultConfiguration()
        config.loggingEnabled = false
        
        // Initialise the SDK with your app Token and Config
        // Token 2.3
        Tapglue.setUpWithAppToken("b27a3e3e9a2747f0138a93794625038f", andConfig: config)
                
        return true
    }
}