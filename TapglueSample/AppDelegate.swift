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
        UITabBar.appearance().tintColor = UIColor(red:0.23, green:0.23, blue:0.23, alpha:1.0)
        
        // Initialise the SDK with your app Token and Config
        Tapglue.setUpWithAppToken("a4ec9947ae00618b6a86b6ea9c01470c")
        
        return true
    }
}