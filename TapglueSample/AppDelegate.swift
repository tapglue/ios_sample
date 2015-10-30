//
//  AppDelegate.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 23.10.15.
//  Copyright © 2015 Tapglue. All rights reserved.
//

import UIKit
import Tapglue

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Black tintColor to change appearence of tabBar image color
        UITabBar.appearance().tintColor = UIColor.blackColor()
        
        // Initialise the SDK with your app Token and Config
        Tapglue.setUpWithAppToken("ec26aa41d61508639b8129f1c0517b07")
        
        return true
    }

}