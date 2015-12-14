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
    @IBOutlet weak var userAboutLabel: UILabel!
    @IBOutlet weak var userFullnameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var friendsCountLabel: UILabel!
    
    override func viewWillAppear(animated: Bool) {
//        Tapglue.retrieveCurrentUserWithCompletionBlock { (myUser : TGUser!, error : NSError!) -> Void in
//            if ((myUser != nil) && (error == nil)) {
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    self.friendsCountLabel.text = String(TGUser.currentUser().friendsCount) + " Friends"
//                })
//            }
//        }
        
        
        
        let tapglueUser = TGUser.currentUser()
        
        let meta = tapglueUser.metadata as AnyObject
        self.userNameLabel.text = tapglueUser.username
        self.userFullnameLabel.text = tapglueUser.firstName + " " + tapglueUser.lastName
        self.userAboutLabel.text = String(meta.valueForKey("about")!)
        
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
    
    @IBAction func editButtonPressed(sender: AnyObject) {
        let user = TGUser.currentUser()
        
        let alertController = UIAlertController(title: "Change Username", message: "Enter new username:", preferredStyle: .Alert)
        alertController.view.frame = CGRectMake(0.0, 0.0, 320.0, 400.0)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .Default) { (_) in
            let newUsername = alertController.textFields?.first?.text
            if (newUsername != nil && newUsername?.characters.count > 2) {
                user.username = newUsername
                user.saveWithCompletionBlock { (success : Bool, error : NSError!) -> Void in
                    if success {
                        // Implementation success.
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.userNameLabel.text = newUsername
                        })
                        print("Username changed: \(newUsername) ")
                    } else {
                        // Implement error handling.
                        print("Server error")
                    }
                }
            } else {
                print("Username wrong")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = user.username
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
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