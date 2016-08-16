//
//  NavigationVC.swift
//  TapglueSample
//
//  Created by Onur Akpolat on 25.10.15.
//  Copyright © 2015 Tapglue. All rights reserved.
//

import UIKit
import Tapglue

class NavigationVC: UINavigationController {
    
    // AppDelegate
    let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    let defaults = NSUserDefaults.standardUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()


    }
    
    override func viewWillAppear(animated: Bool) {
        // Send user to app or login screen
        if self.appDel.rxTapglue.currentUser != nil {
            
        } else {
            setupFilterCheckmarkDefaults()
            setupSocialPermissionDefaults()
            
            // Show loginVC if no user
            performSegueWithIdentifier("loginSegue", sender: nil)
        }
    }
    
    // Prepare checks to filter Notifications
    func setupFilterCheckmarkDefaults(){
        let filterCheckmarks: [Bool] = [true, true, true]
        defaults.setObject(filterCheckmarks, forKey: "filterCheckmarks")
        defaults.synchronize()
    }
    
    // Prepare permissions for FindUsersVC
    func setupSocialPermissionDefaults(){
        defaults.setObject(false, forKey: "facebookPermission")
        defaults.setObject(false, forKey: "twitterPermission")
        defaults.synchronize()
    }
}