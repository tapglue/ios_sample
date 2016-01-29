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
        config.loggingEnabled = true
        Tapglue.setUpWithAppToken("1ecd50ce4700e0c8f501dee1fb271344", andConfig: config)
        
        // Init Twitter
        Twitter.sharedInstance().startWithConsumerKey("jwcnpghUsKBjD3lMpdoMlSpuK", consumerSecret: "ibzxpfK76SZMNhE5sqWa7devupSCtVWOt1WpYrgOi8yZw7AtnU")
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool
    {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
}