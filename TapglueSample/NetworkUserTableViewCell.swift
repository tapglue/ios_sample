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
    
    // Get the AppDelegate
    let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate

    var cellUser = User()
    
    var searchingForUser = false
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var connectLeftButton: UIButton!
    @IBOutlet weak var connectRightButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
        userImageView.layer.masksToBounds = true
    }
    
    // Configure Cell with User data
    func configureCellWithUserWithPendingConnection(user: User!){
        cellUser = user
        
        self.userNameLabel.text = self.cellUser.username
        
        // TODO: Check nil
        // UserImage
        let profileImage = cellUser.images!["profile"]
        self.userImageView.kf_setImageWithURL(NSURL(string: profileImage!.url!)!)
        
        if self.connectRightButton != nil {
            acceptFriendShipCustomizeButton()
        }
        
        if self.connectLeftButton != nil {
            declineFriendShipCustomizeButton()
        }
    }
    
    // Configure Cell with User data when search is active
    func configureCellWithUserToFriendOrFollow(user: User!){
        cellUser = user
        
        self.userNameLabel.text = self.cellUser.username
        
        // TODO: Check nil
        // UserImage
        let profileImage = cellUser.images!["profile"]
        self.userImageView.kf_setImageWithURL(NSURL(string: profileImage!.url!)!)
        
        if self.connectRightButton != nil {
            if cellUser.isFriend! {
                friendUserCustomizeButton()
                self.connectRightButton.selected = true
            } else {
                unfriendUserCustomizeButton()
                self.connectRightButton.selected = false
            }
        }
        
        if self.connectLeftButton != nil {
            if cellUser.isFollowed! {
                followingUserCustomizeButton()
                self.connectLeftButton.selected = true
            } else {
                unfollowingUserCustomizeButton()
                self.connectLeftButton.selected = false
            }
        }
    }

    
    @IBAction func connectRightPressed(sender: UIButton) {
        // OldSDK TODO: Turn on with new sdk
        if searchingForUser {
            if sender.selected {
                // NewSDK
                appDel.rxTapglue.deleteConnection(toUserId: cellUser.id!, type: .Friend).subscribe({ (event) in
                    switch event {
                    case .Next( _):
                        print("Next")
                    case .Error(let error):
                        self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                    case .Completed:
                        print("Do the action")
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            sender.selected = false
                            self.unfriendUserCustomizeButton()
                        })
                    }
                }).addDisposableTo(self.appDel.disposeBag)
                
                // OldSDK
//                Tapglue.unfriendUser(cellUser, withCompletionBlock: { (success: Bool,error: NSError!) -> Void in
//                    if success {
//                        print("User unfriend successful")
//                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                            sender.selected = false
//                            self.unfriendUserCustomizeButton()
//                        })
//                    } else if error != nil{
//                        print("\nError unfriendUser: \(error)")
//                    }
//                })
            } else {
                print("Start connecting as friend")
                let connection = Connection(toUserId: cellUser.id!, type: .Friend, state: .Pending)
                appDel.rxTapglue.createConnection(connection).subscribe({ (event) in
                    switch event {
                    case .Next( _):
                        print("Cell USER ID to friend\(self.cellUser.id!)")
                        print("Next")
                    case .Error(let error):
                        self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                    case .Completed:
                        print("Do the action")
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            sender.selected = true
                            self.pendingUserCustomizeButton()
                        })
                    }
                }).addDisposableTo(self.appDel.disposeBag)
                
                // OldSDK
//                Tapglue.friendUser(cellUser, withState: TGConnectionState.Pending, withCompletionBlock: { (success : Bool, error : NSError!) -> Void in
//                    if success {
//                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                            sender.selected = true
//                            self.pendingUserCustomizeButton()
//                        })
//                    } else if error != nil{
//                        print("\nError friendUser: \(error)")
//                    }
//                })
            }
        } else {
            let connection = Connection(toUserId: cellUser.id!, type: .Friend, state: .Confirmed)
            appDel.rxTapglue.createConnection(connection).subscribe({ (event) in
                switch event {
                case .Next( _):
                    print("Next")
                case .Error(let error):
                    self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                case .Completed:
                    print("Do the action")
                }
            }).addDisposableTo(self.appDel.disposeBag)
            
            // OldSDK TODO: Find out how to handle friendship conformation
//            Tapglue.friendUser(cellUser, withState: TGConnectionState.Confirmed, withCompletionBlock: { (success : Bool, error : NSError!) -> Void in
//                if success {
//                    print(success)
//                } else if error != nil{
//                    print("\nError friendUser: \(error)")
//                }
//            })
        }
    }
    
    @IBAction func connectLeftPressed(sender: UIButton) {
        //OldSDK TODO: Turn on with new sdk
        if searchingForUser {
            if sender.selected {
                
                // NewSDK
                appDel.rxTapglue.deleteConnection(toUserId: cellUser.id!, type: .Follow).subscribe({ (event) in
                    switch event {
                    case .Next( _):
                        print("Next")
                    case .Error(let error):
                        self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                    case .Completed:
                        print("Do the action")
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            sender.selected = false
                            self.unfollowingUserCustomizeButton()
                        })
                    }
                }).addDisposableTo(self.appDel.disposeBag)

            } else {
                let connection = Connection(toUserId: cellUser.id!, type: .Follow, state: .Confirmed)
                appDel.rxTapglue.createConnection(connection).subscribe({ (event) in
                    switch event {
                    case .Next( _):
                        print("Next")
                    case .Error(let error):
                        self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                    case .Completed:
                        print("Do the action")
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            sender.selected = true
                            self.followingUserCustomizeButton()
                        })
                    }
                }).addDisposableTo(self.appDel.disposeBag)
            }
        } else {
            let connection = Connection(toUserId: cellUser.id!, type: .Friend, state: .Rejected)
            appDel.rxTapglue.createConnection(connection).subscribe({ (event) in
                switch event {
                case .Next( _):
                    print("Next")
                case .Error(let error):
                    self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                case .Completed:
                    print("Do the action")
                }
            }).addDisposableTo(self.appDel.disposeBag)
            
            //OldSDK TODO: how to handle rejected connection?
//            Tapglue.friendUser(cellUser, withState: TGConnectionState.Rejected, withCompletionBlock: { (success : Bool, error : NSError!) -> Void in
//                if success {
//                    print(success)
//                } else if error != nil{
//                    print("\nError friendUser: \(error)")
//                }
//            })
        }
    }
        
    
    func acceptFriendShipCustomizeButton(){
        self.connectRightButton.setTitle("Accept", forState: .Normal)
        self.connectRightButton.backgroundColor = UIColor(red:0.016, green:0.859, blue:0.675, alpha:1)
    }
    func declineFriendShipCustomizeButton(){
        self.connectLeftButton.setTitle("Decline", forState: .Normal)
        self.connectLeftButton.backgroundColor = UIColor.redColor()
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
}
