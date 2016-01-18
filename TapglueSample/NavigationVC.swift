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
    
    let defaults = NSUserDefaults.standardUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Send user to app or login screen
        if TGUser.currentUser() != nil {
            
        } else {
            setupCheckedForEventsDefaults()
            setupPermissionDefaultBools()
            // Show loginVC if no user
            performSegueWithIdentifier("loginSegue", sender: nil)
        }
    }
    
    // Prepare checks to filter Notifications
    func setupCheckedForEventsDefaults(){
        let checked: [Bool] = [true, true, true, true, true]
        defaults.setObject(checked, forKey: "checked")
        defaults.synchronize()
    }
    
    // Prepare permissions for FindUsersVC
    func setupPermissionDefaultBools(){
        defaults.setObject(false, forKey: "facebookPermission")
        defaults.setObject(false, forKey: "twitterPermission")
        defaults.synchronize()
    }
}