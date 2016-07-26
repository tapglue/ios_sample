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
import TapglueSims


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let appToken = "1ecd50ce4700e0c8f501dee1fb271344"
    let url = "https://api.tapglue.com"
    var sims: TapglueSims!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        
        // Init TapglueSims and Tapglue with your appToken and Config plus environment
        sims = TapglueSims(appToken: appToken, url: url, environment: .Sandbox)
        registerForPushNotifications(application)
        let config = TGConfiguration.defaultConfiguration()
        config.loggingEnabled = false
        Tapglue.setUpWithAppToken(appToken, andConfig: config)
        Tapglue.setSessionTokenNotifier(sims)
        
        
        // Init Twitter
        Twitter.sharedInstance().startWithConsumerKey("jwcnpghUsKBjD3lMpdoMlSpuK", consumerSecret: "ibzxpfK76SZMNhE5sqWa7devupSCtVWOt1WpYrgOi8yZw7AtnU")
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // Push Notifications related methods
    func registerForPushNotifications(application: UIApplication) {
        sims.registerSimsNotificationSettings(application)
    }
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .None {
            application.registerForRemoteNotifications()
        }
    }
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        sims.registerDeviceToken(deviceToken)
    }
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Failed to register:", error)
    }
    func application(application: UIApplication, didReceiveRemoteNotification notificationSettings: [NSObject : AnyObject]) {
        print(notificationSettings)
    }
    
    
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
}