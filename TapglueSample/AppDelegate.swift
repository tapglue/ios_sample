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
        config.log = false
        rxTapglue = RxTapglue(configuration: config)
        
        sims = TapglueSims(withConfiguration: config, environment: .Sandbox)
        registerForPushNotifications(application)
        
        
        // configure authentication with Cognito
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: region,
                                                                identityPoolId:cognitoIdentityPoolId)
        let configuration = AWSServiceConfiguration(region: region, credentialsProvider: credentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
        
        // Handle push notification if app is inactive
        if let remoteNotification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as! [NSObject : AnyObject]? {
            //do stuff with notification
            self.application(application, didReceiveRemoteNotification: remoteNotification)
        }
        
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
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        if let urn = NSURL(string: userInfo["urn"] as! String) {
            switch urn.pathComponents![1] {
            case "posts":
                retrievePostWithIDAndUserWithID(urn.pathComponents![urn.pathComponents!.indexOf("posts")!+1])
            case "users":
                retrieveUserWithID(urn.pathComponents![urn.pathComponents!.indexOf("users")!+1])
            default: ""
            }
        }
    
    }
    
    //Mark: - Tapglue
    func retrievePostWithIDAndUserWithID(postID: String) {
        rxTapglue.retrievePost(postID).subscribe({ (event) in
            switch event {
            case .Next(let post):
                
                let rootViewController = self.window?.rootViewController as! UINavigationController
                let storyboard = UIStoryboard(name: "PostDetail", bundle: nil)
                let pdVC = storyboard.instantiateViewControllerWithIdentifier("PostDetailViewController") as!
                PostDetailVC
                
                pdVC.post = post
                
                self.rxTapglue.retrieveUser(post.userId!).subscribe { (event) in
                    switch event {
                    case .Next(let usr):
                        pdVC.usr = usr
                        
                    case .Error(let error):
                        self.printOutErrorMessageAndCode(error as? TapglueError)
                    case .Completed:
                        rootViewController.pushViewController(pdVC, animated: false)
                    }
                    }.addDisposableTo(self.disposeBag)
                
            case .Error(let error):
                self.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                break
            }
        }).addDisposableTo(disposeBag)
    }
    
    func retrieveUserWithID(userID: String) {
        let rootViewController = self.window?.rootViewController as! UINavigationController
        let storyboard = UIStoryboard(name: "UserProfile", bundle: nil)
        let upVC = storyboard.instantiateViewControllerWithIdentifier("UserProfileViewController") as!
        UserProfileVC
        
        self.rxTapglue.retrieveUser(userID).subscribe { (event) in
            switch event {
            case .Next(let usr):
                upVC.userProfile = usr
                
            case .Error(let error):
                self.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                rootViewController.pushViewController(upVC, animated: false)
            }
        }.addDisposableTo(self.disposeBag)
    }
    
    func printOutErrorMessageAndCode(err: TapglueError?) {
        print(err?.code)
        print(err?.message)
    }
    
    // Facebook
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
