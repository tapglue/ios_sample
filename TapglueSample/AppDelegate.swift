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
        
        // Black tintColor to change appearence of tabBar image color
//        UITabBar.appearance().tintColor = UIColor(red:0.23, green:0.23, blue:0.23, alpha:1.0)
        
        // Init the SDK with your app Token and Config
        // Token 2.3
        let config = TGConfiguration.defaultConfiguration()
        config.loggingEnabled = false
        Tapglue.setUpWithAppToken("b27a3e3e9a2747f0138a93794625038f", andConfig: config)
        
        // Twitter init
        Twitter.sharedInstance().startWithConsumerKey("jwcnpghUsKBjD3lMpdoMlSpuK", consumerSecret: "ibzxpfK76SZMNhE5sqWa7devupSCtVWOt1WpYrgOi8yZw7AtnU")
//        Fabric.with([Twitter.sharedInstance()])
        
        
//        Tapglue.retrievePendingConncetionsForCurrentUserWithCompletionBlock { (incoming: [AnyObject]!, outgoing: [AnyObject]!, error: NSError!) -> Void in
//            if error != nil {
//                print("\nError happened")
//                print(error)
//            }
//            else {
//                print("\nSuccess happened")
//                var users: [TGUser] = []
//                
//                for inc in incoming {
//                    users.append((inc as! TGConnection).fromUser)
//                }
//            }
//        }
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool
    {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
}