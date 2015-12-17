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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Check for tapglue user
        if TGUser.currentUser() != nil {
            print(TGUser.currentUser())
        } else {
            setupCheckedForEvents()
            
            // Show loginVC if no user
            performSegueWithIdentifier("loginSegue", sender: nil)
        }
    }
    
    // TapglueSample uses 3 event types
    func setupCheckedForEvents(){
        let checked: [Bool] = [true, true, true]
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(checked, forKey: "checked")
        defaults.synchronize()
    }
}