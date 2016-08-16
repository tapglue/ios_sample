//
//  UsersVC.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 15/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue

class UsersVC: UIViewController, UITableViewDelegate {
    
    var users: [User] = []
    
    var meta: AnyObject?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension UsersVC: UITableViewDataSource {
    // MARK: - TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UsersTableViewCell
        
        cell.userImageView.image = nil
        
        // OldSDK TODO: Fix if about is available
//        meta = users[indexPath.row].metadata as AnyObject
//        if meta != nil {
//            cell.userAboutLabel.text = String(meta!.valueForKey("about")!)
//        }
        
        cell.userNameLabel.text = users[indexPath.row].username
        
        // OldSDK TODO: Fix image
//        // User image
//        var userImage = TGImage()
//        userImage = users[indexPath.row].images.valueForKey("profilePic") as! TGImage
//        cell.userImageView.kf_setImageWithURL(NSURL(string: userImage.url)!)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "UserProfile", bundle: nil)
        let userProfileViewController = storyboard.instantiateViewControllerWithIdentifier("UserProfileViewController") as! UserProfileVC
        
        userProfileViewController.userProfile = self.users[indexPath.row]
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.navigationController?.pushViewController(userProfileViewController, animated: true)
        })
    }
}