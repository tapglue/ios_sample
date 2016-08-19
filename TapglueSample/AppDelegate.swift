//
//  AppDelegate.swift
//  TapglueSample
//
//  Created by Onur Akpolat on 23.10.15.
//  Copyright © 2015 Tapglue. All rights reserved.
//

import UIKit
import Tapglue
import RxSwift


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let appToken = "02930ef5d193f8c78e5d8c7d80a5a9dc"
    let url = "https://api.tapglue.com"
    var sims: TapglueSims!
    var rxTapglue: RxTapglue!
    
    let disposeBag = DisposeBag()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let config = Configuration()
        config.baseUrl = url
        config.appToken = appToken
        // setting this to true makes the sdk print http requests and responses
        config.log = false
        rxTapglue = RxTapglue(configuration: config)
        
        sims = TapglueSims(withConfiguration: config, environment: .Sandbox)
        registerForPushNotifications(application)
        
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
    
    // Custom TapglueError method
    func printOutErrorMessageAndCode(err: TapglueError?) {
        print(err?.code)
        print(err?.message)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        // TODO: FacebookTODO
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
}
