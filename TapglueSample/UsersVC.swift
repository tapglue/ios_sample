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
    
    var users: [TGUser] = []
    
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
        
        meta = users[indexPath.row].metadata as AnyObject
        if meta != nil {
            cell.userAboutLabel.text = String(meta!.valueForKey("about")!)
        }
        
        cell.userNameLabel.text = users[indexPath.row].username
        
        // User image
        var userImage = TGImage()
        userImage = users[indexPath.row].images.valueForKey("profilePic") as! TGImage
        cell.userImageView.downloadedFrom(link: userImage.url, contentMode: .ScaleAspectFill)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let userProfileViewController = self.storyboard?.instantiateViewControllerWithIdentifier("UserProfileViewController") as! UserProfileVC
        
        userProfileViewController.userProfile = self.users[indexPath.row]
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.navigationController?.pushViewController(userProfileViewController, animated: true)
        })
    }
}