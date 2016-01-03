//
//  NetworkUserTableViewCell.swift
//  TapglueSample
//
//  Created by Onur Akpolat on 25/10/15.
//  Copyright © 2015 Tapglue. All rights reserved.
//

import UIKit
import Tapglue

class NetworkUserTableViewCell: UITableViewCell {

    var cellUser = TGUser()
    
    @IBOutlet weak var userAboutLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var connectLeftButton: UIButton!
    @IBOutlet weak var connectRightButton: UIButton!
    
    var checkingForPendingConnections = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
        userImageView.layer.masksToBounds = true
    }
    
    // Configure Cell with TGUser data
    func configureCellWithUserToFriendOrFollow(user: TGUser!){
        cellUser = user
        
        let meta = user.metadata as AnyObject
        self.userAboutLabel.text = String(meta.valueForKey("about")!)
        
        self.userNameLabel.text = self.cellUser.username
        
        // UserImage
        var userImage = TGImage()
        userImage = cellUser.images.valueForKey("profilePic") as! TGImage
        self.userImageView.downloadedFrom(link: userImage.url, contentMode: .ScaleAspectFill)
        
        if self.connectRightButton != nil {
            if cellUser.isFriend {
                friendUserCustomizeButton()
                self.connectRightButton.selected = true
            } else {
                unfriendUserCustomizeButton()
                self.connectRightButton.selected = false
            }
        }
        
        if self.connectLeftButton != nil {
            if cellUser.isFollowed {
                followingUserCustomizeButton()
                self.connectLeftButton.selected = true
            } else {
                unfollowingUserCustomizeButton()
                self.connectLeftButton.selected = false
            }
        }
    }
    
    // Configure Cell with TGUser data
    func configureCellWithUserWithPendingConnection(user: TGUser!){
        cellUser = user
        
        let meta = user.metadata as AnyObject
        
        self.userAboutLabel.text = String(meta.valueForKey("about")!)
        self.userNameLabel.text = self.cellUser.username
        
        
        // UserImage
        var userImage = TGImage()
        userImage = cellUser.images.valueForKey("profilePic") as! TGImage
        self.userImageView.downloadedFrom(link: userImage.url, contentMode: .ScaleAspectFill)
        
        if self.connectRightButton != nil {
            acceptFriendShipCustomizeButton()
        }
        
        if self.connectLeftButton != nil {
            declineFriendShipCustomizeButton()
        }
    }
    
    // Configure Cell with Contacts that use the app
    func configureCellWithUserFromContactsThatUsesApp(contact: [String:String], user: TGUser){
        cellUser = user
        
        self.userAboutLabel.text = ""
        self.userNameLabel.text = contact["givenName"]
        
        self.connectRightButton.hidden = false
        self.connectLeftButton.hidden = true
        
        if self.connectRightButton != nil {
            if user.isFriend {
                self.friendUserCustomizeButton()
                self.connectRightButton.selected = true
            } else {
                self.unfriendUserCustomizeButton()
                self.connectRightButton.selected = false
            }
        }
    }
    
    // Configure Cell with Contacts that need to be invited
    func configureCellWithUserFromContacts(contact: [String:String]){
        self.userAboutLabel.text = ""
        self.userNameLabel.text = contact["givenName"]
        
        self.connectRightButton.hidden = true
        
        inviteCustomizeButton()
    }
    
    @IBAction func connectRightPressed(sender: UIButton) {
        if sender.selected {
            Tapglue.unfriendUser(cellUser, withCompletionBlock: { (success: Bool,error: NSError!) -> Void in
                if success {
                    print("User unfriend successful")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        sender.selected = false
                        self.unfriendUserCustomizeButton()
                    })
                } else if error != nil{
                    print("\nError unfriendUser: \(error)")
                }
            })
        } else {
            if !checkingForPendingConnections {
                Tapglue.friendUser(cellUser, withState: TGConnectionState.Pending, withCompletionBlock: { (success : Bool, error : NSError!) -> Void in
                    if success {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            sender.selected = true
                            self.pendingUserCustomizeButton()
                        })
                    } else if error != nil{
                        print("\nError friendUser: \(error)")
                    }
                })
            } else {
                Tapglue.friendUser(cellUser, withState: TGConnectionState.Confirmed, withCompletionBlock: { (success : Bool, error : NSError!) -> Void in
                    if success {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            sender.selected = true
                            self.friendUserCustomizeButton()
                            self.connectLeftButton.hidden = true
                        })
                    } else if error != nil{
                        print("\nError friendUser: \(error)")
                    }
                })
            }
        }
    }
    
    @IBAction func connectLeftPressed(sender: UIButton) {
        if sender.selected {
            Tapglue.unfollowUser(cellUser, withCompletionBlock: { (success: Bool, error: NSError!) -> Void in
                if success {
                    print("User unfollow successful")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        sender.selected = false
                        self.unfollowingUserCustomizeButton()
                    })
                } else if error != nil{
                    print("\nError unfollowUser: \(error)")
                }
            })
        } else {
            if !checkingForPendingConnections {
                Tapglue.followUser(cellUser, withCompletionBlock: { (success: Bool, error: NSError!) -> Void in
                    if success {
                        print("User follow successful: \(success)")
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            sender.selected = true
                            self.followingUserCustomizeButton()
                        })
                    } else if error != nil{
                        print("\nError followUser: \(error)")
                    }
                })
            } else {
                Tapglue.friendUser(cellUser, withState: TGConnectionState.Rejected, withCompletionBlock: { (success : Bool, error : NSError!) -> Void in
                    if success {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            sender.selected = true
                            self.unfriendUserCustomizeButton()
                        })
                    } else if error != nil{
                        print("\nError friendUser: \(error)")
                    }
                })
            }

        }
    }
    
    
    func followingUserCustomizeButton(){
        self.connectLeftButton.setTitle("Following", forState: .Selected)
        self.connectLeftButton.backgroundColor = UIColor(red:0.016, green:0.859, blue:0.675, alpha:1)
    }
    func unfollowingUserCustomizeButton(){
        self.connectLeftButton.setTitle("Follow", forState: .Normal)
        self.connectLeftButton.backgroundColor = UIColor.lightGrayColor()
    }
    
    func friendUserCustomizeButton(){
        self.connectRightButton.setTitle("Friend", forState: .Selected)
        self.connectRightButton.backgroundColor = UIColor(red:0.016, green:0.859, blue:0.675, alpha:1)
    }
    func unfriendUserCustomizeButton(){
        self.connectRightButton.setTitle("Add Friend", forState: .Normal)
        self.connectRightButton.backgroundColor = UIColor.lightGrayColor()
    }
    
    func pendingUserCustomizeButton(){
        self.connectRightButton.setTitle("Pending", forState: .Selected)
        self.connectRightButton.backgroundColor = UIColor.orangeColor()
    }
    
    func acceptFriendShipCustomizeButton(){
        self.connectRightButton.setTitle("Accept", forState: .Normal)
        self.connectRightButton.backgroundColor = UIColor.orangeColor()
    }
    func declineFriendShipCustomizeButton(){
        self.connectLeftButton.setTitle("Decline", forState: .Normal)
        self.connectLeftButton.backgroundColor = UIColor.redColor()
    }
    
    func inviteCustomizeButton(){
        self.connectLeftButton.setTitle("Invite", forState: .Normal)
        self.connectLeftButton.backgroundColor = UIColor.lightGrayColor()
    }
}
