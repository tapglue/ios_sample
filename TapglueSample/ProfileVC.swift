//
//  ProfileVC.swift
//  TapglueSample
//
//  Created by Onur Akpolat on 23.10.15.
//  Copyright © 2015 Tapglue. All rights reserved.
//

import UIKit
import Tapglue

class ProfileVC: UIViewController {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    override func viewWillAppear(animated: Bool) {
        self.userNameLabel.text = TGUser.currentUser().username
        
        var userImage = TGImage()
        userImage = TGUser.currentUser().images.valueForKey("avatar") as! TGImage
        
        self.userImageView.image = UIImage(named: userImage.url)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        Tapglue.logoutWithCompletionBlock { (success: Bool, error: NSError!) -> Void in
            if success {
                print("User logged out")
            } else if error != nil{
                print("Error happened\n")
                print(error)
            }
        }
        self.navigationController?.performSegueWithIdentifier("loginSegue", sender: nil)
    }
    
    @IBAction func thumbEventButton(sender: AnyObject) {
        Tapglue.createEventWithType("Likes your status", onObjectWithId: "ThumbFilled")
        
    }
    
    @IBAction func starEventButton(sender: AnyObject) {
        Tapglue.createEventWithType("Saved this article", onObjectWithId: "StarFilled")
    }
    
    @IBAction func heartEventButton(sender: AnyObject) {
        Tapglue.createEventWithType("Loves your Picture", onObjectWithId: "HeartFilled")
    }
}