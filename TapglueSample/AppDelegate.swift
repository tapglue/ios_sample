//
//  AppDelegate.swift
//  TapglueSample
//
//  Created by Onur Akpolat on 23.10.15.
//  Copyright © 2015 Tapglue. All rights reserved.
//

import UIKit
import Tapglue
import TwitterKit
import Fabric

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Init Tapglue with your app Token and Configuration
        let config = TGConfiguration.defaultConfiguration()
        config.loggingEnabled = false
        Tapglue.setUpWithAppToken("e43d15fd9b71b0938d2c66b27f8c5c2b", andConfig: config)
        
        // Init Twitter
        Twitter.sharedInstance().startWithConsumerKey("jwcnpghUsKBjD3lMpdoMlSpuK", consumerSecret: "ibzxpfK76SZMNhE5sqWa7devupSCtVWOt1WpYrgOi8yZw7AtnU")
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool
    {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
}