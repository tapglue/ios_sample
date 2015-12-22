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

        // Check for tapglue user
        if TGUser.currentUser() != nil {
            print(TGUser.currentUser())
        } else {
            setupCheckedForEventsDefaults()
            setupPermissionDefaultBools()
            // Show loginVC if no user
            performSegueWithIdentifier("loginSegue", sender: nil)
        }
    }
    
    // TapglueSample uses 3 event types
    func setupCheckedForEventsDefaults(){
        let checked: [Bool] = [true, true, true, true]
        defaults.setObject(checked, forKey: "checked")
        defaults.synchronize()
    }
    
    // Setup permission control for NetworkVC(networkButton)
    func setupPermissionDefaultBools(){
        defaults.setObject(false, forKey: "contactsPermission")
        defaults.setObject(false, forKey: "facebookPermission")
        defaults.setObject(false, forKey: "twitterPermission")
        defaults.synchronize()
    }
}