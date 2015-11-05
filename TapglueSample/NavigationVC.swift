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
            // Show loginVC if no user
            performSegueWithIdentifier("loginSegue", sender: nil)
        }
    }
}