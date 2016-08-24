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
import AWSS3


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let appToken = "02930ef5d193f8c78e5d8c7d80a5a9dc"
    let url = "https://api.tapglue.com"
    var sims: TapglueSims!
    var rxTapglue: RxTapglue!
    
    let disposeBag = DisposeBag()
    
    // AWS
    let S3BucketName = "tapglue-sampleapp"
    let cognitoAccountId = "775034650473"
    let cognitoIdentityPoolId = "eu-west-1:9b74dda9-5643-479c-a6c4-88d2871ec787"
    let region = AWSRegionType.EUWest1

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let config = Configuration()
        config.baseUrl = url
        config.appToken = appToken
        // If you like to see logs: set true
        config.log = true
        rxTapglue = RxTapglue(configuration: config)
        
        sims = TapglueSims(withConfiguration: config, environment: .Sandbox)
        registerForPushNotifications(application)
        
        
        // configure authentication with Cognito
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: region,
                                                                identityPoolId:cognitoIdentityPoolId)
        let configuration = AWSServiceConfiguration(region: region, credentialsProvider: credentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
        
        
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
    
    // TapglueError handel
    func printOutErrorMessageAndCode(err: TapglueError?) {
        print(err?.code)
        print(err?.message)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    // AWS
    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
        /*
         Store the completion handler.
         */
        AWSS3TransferUtility.interceptApplication(application, handleEventsForBackgroundURLSession: identifier, completionHandler: completionHandler)
    }
}
