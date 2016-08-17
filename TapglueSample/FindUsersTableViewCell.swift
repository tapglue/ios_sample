//
//  FindUsersTableViewCell.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 04/01/16.
//  Copyright © 2016 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue

class FindUsersTableViewCell: UITableViewCell {
    
    // Get the AppDelegate
    let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    var cellUser = User()
    
    @IBOutlet weak var userAboutLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var connectLeftButton: UIButton!
    @IBOutlet weak var connectRightButton: UIButton!
    
    
    let inviteTag = 10

    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
        userImageView.layer.masksToBounds = true
    }
    
    // Configure Cell with TGUser data
    func configureCellWithUserToFriendOrFollow(user: User!){
        cellUser = user
        
        // OldSDK
//        let meta = user.metadata as AnyObject
//        self.userAboutLabel.text = String(meta.valueForKey("about")!)
        
        self.userNameLabel.text = self.cellUser.username
        
        // OldSDK
//        showUserImage(cellUser)
        
        if self.connectRightButton != nil {
            if cellUser.isFriend! {
                customizeBtn(.Friend)
                self.connectRightButton.selected = true
            } else {
                customizeBtn(.Unfriend)
                self.connectRightButton.selected = false
            }
        }
        
        if self.connectLeftButton != nil {
            if cellUser.isFollowed! {
                customizeBtn(.Follow)
                self.connectLeftButton.selected = true
            } else {
                customizeBtn(.Unfollow)
                self.connectLeftButton.selected = false
            }
        }
    }
    
    // Configure Cell with TGUser data
    func configureCellWithUserWithPendingConnection(user: User!){
        cellUser = user
        // OldSDK
//        let meta = user.metadata as AnyObject
//        self.userAboutLabel.text = String(meta.valueForKey("about")!)
        
        self.userNameLabel.text = self.cellUser.username
        
        // OldSDK
//        showUserImage(cellUser)
        
        if self.connectRightButton != nil {
            customizeBtn(.Accept)
        }
        
        if self.connectLeftButton != nil {
            customizeBtn(.Decline)
        }
    }
    
    // Configure Cell with Contacts that use the app
    func configureCellWithUserFromContactsThatUsesApp(contact: [String:String], user: User){
        cellUser = user
        // OldSDK
//        let meta = cellUser.metadata as AnyObject
//        self.userAboutLabel.text = String(meta.valueForKey("about")!)
        
        self.userNameLabel.text = contact["givenName"]
        
        // OldSDK
//        showUserImage(cellUser)
        
//        if self.connectRightButton != nil {
//            self.connectRightButton.hidden = false
        
            if user.isFriend! {
                customizeBtn(.Friend)
                self.connectRightButton.selected = true
            } else {
                customizeBtn(.Unfriend)
                self.connectRightButton.selected = false
            }
//        }
//        if self.connectLeftButton != nil {
//            self.connectLeftButton.hidden = false
        
            if user.isFollowing! {
//                self.followingUserCustomizeButton()
                customizeBtn(.Follow)
                self.connectLeftButton.selected = true
            } else {
                customizeBtn(.Unfollow)
                self.connectLeftButton.selected = false
            }
//        }
    }
    
    // Configure Cell with Contacts that need to be invited
    func configureCellWithUserFromContacts(contact: [String:String]){
        // TODO: Add invite process
        self.userAboutLabel.text = contact["email"]
        self.userNameLabel.text = contact["givenName"]
        
        customizeBtn(.Invite)
    }
    
    @IBAction func connectRightPressed(sender: UIButton) {
        connectRightBtnState(sender)
    }
    
    @IBAction func connectLeftPressed(sender: UIButton) {
        connectLeftBtnState(sender)
    }
    
    
//    func followingUserCustomizeButton(){
//        self.connectLeftButton.setTitle("Following", forState: .Selected)
//        self.connectLeftButton.backgroundColor = UIColor(red:0.016, green:0.859, blue:0.675, alpha:1)
//        self.connectLeftButton.tag = BtnState.Unfollow.rawValue
//    }
//    func unfollowingUserCustomizeButton(){
//        self.connectLeftButton.setTitle("Follow", forState: .Normal)
//        self.connectLeftButton.backgroundColor = UIColor.lightGrayColor()
//        self.connectLeftButton.tag = BtnState.Follow.rawValue
//    }
//    
//    func friendUserCustomizeButton(){
//        self.connectRightButton.setTitle("Friend", forState: .Selected)
//        self.connectRightButton.backgroundColor = UIColor(red:0.016, green:0.859, blue:0.675, alpha:1)
//        self.connectRightButton.tag = BtnState.Unfriend.rawValue
//    }
//    func unfriendUserCustomizeButton(){
//        self.connectRightButton.setTitle("Add Friend", forState: .Normal)
//        self.connectRightButton.backgroundColor = UIColor.lightGrayColor()
//        self.connectRightButton.tag = BtnState.Friend.rawValue
//    }
//    
//    func pendingUserCustomizeButton(){
//        self.connectRightButton.setTitle("Pending", forState: .Selected)
//        self.connectRightButton.backgroundColor = UIColor.orangeColor()
//        self.connectRightButton.tag = BtnState.Pending.rawValue
//    }
//    
//    func acceptFriendShipCustomizeButton(){
//        self.connectRightButton.setTitle("Accept", forState: .Normal)
//        self.connectRightButton.backgroundColor = UIColor.orangeColor()
//        self.connectRightButton.tag = BtnState.Accept.rawValue
//    }
//    func declineFriendShipCustomizeButton(){
//        self.connectLeftButton.setTitle("Decline", forState: .Normal)
//        self.connectLeftButton.backgroundColor = UIColor.redColor()
//        self.connectLeftButton.tag = BtnState.Decline.rawValue
//    }
//    
//    func inviteCustomizeButton(){
//        self.connectLeftButton.setTitle("Invite", forState: .Normal)
//        self.connectLeftButton.backgroundColor = UIColor.lightGrayColor()
//        self.connectLeftButton.tag = BtnState.Invite.rawValue
//        self.connectRightButton.hidden = true
//    }
    
    func customizeBtn(state: BtnState) {
        switch state {
        case .Invite:
            self.connectLeftButton.setTitle("Invite", forState: .Normal)
            self.connectLeftButton.backgroundColor = UIColor.lightGrayColor()
            self.connectLeftButton.tag = BtnState.Invite.rawValue
//            self.connectRightButton.hidden = true
        case .Follow:
            self.connectLeftButton.setTitle("Following", forState: .Selected)
            self.connectLeftButton.backgroundColor = UIColor(red:0.016, green:0.859, blue:0.675, alpha:1)
            self.connectLeftButton.tag = BtnState.Unfollow.rawValue
        case .Unfollow:
            self.connectLeftButton.setTitle("Follow", forState: .Normal)
            self.connectLeftButton.backgroundColor = UIColor.lightGrayColor()
            self.connectLeftButton.tag = BtnState.Follow.rawValue
        case .Friend:
            self.connectRightButton.setTitle("Add Friend", forState: .Selected)
            self.connectRightButton.backgroundColor = UIColor(red:0.016, green:0.859, blue:0.675, alpha:1)
            self.connectRightButton.tag = BtnState.Unfriend.rawValue
        case .Unfriend:
            self.connectRightButton.setTitle("Friend", forState: .Normal)
            self.connectRightButton.backgroundColor = UIColor.lightGrayColor()
            self.connectRightButton.tag = BtnState.Friend.rawValue
        case .Pending:
            self.connectRightButton.setTitle("Pending", forState: .Selected)
            self.connectRightButton.backgroundColor = UIColor.orangeColor()
            self.connectRightButton.tag = BtnState.Pending.rawValue
        case .Accept:
            self.connectRightButton.setTitle("Accept", forState: .Normal)
            self.connectRightButton.backgroundColor = UIColor.orangeColor()
            self.connectRightButton.tag = BtnState.Accept.rawValue
        case .Decline:
            self.connectLeftButton.setTitle("Decline", forState: .Normal)
            self.connectLeftButton.backgroundColor = UIColor.redColor()
            self.connectLeftButton.tag = BtnState.Decline.rawValue
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // OldSDK
//    func showUserImage(cellUser: TGUser) {
//        // UserImage
//        var userImage = TGImage()
//        userImage = cellUser.images.valueForKey("profilePic") as! TGImage
//        self.userImageView.kf_setImageWithURL(NSURL(string: userImage.url)!)
//    }
    
    func connectLeftBtnState(sender: UIButton){
        switch sender.tag {
        case BtnState.Invite.rawValue:
            print("Invite")
        case BtnState.Follow.rawValue:
            print("Follow")
            
            // NewSDK
            let connect = Connection(toUserId: cellUser.id!, type: .Follow, state: .Confirmed)
            
            appDel.rxTapglue.createConnection(connect).subscribe({ (event) in
                switch event {
                case .Next( _):
                    print("Next")
                case .Error(let error):
                    self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                case .Completed:
                    print("Do the action")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        sender.selected = true
                        self.customizeBtn(.Follow)
                    })
                }
            }).addDisposableTo(self.appDel.disposeBag)
            
            // OldSDK
//            Tapglue.followUser(cellUser, withCompletionBlock: { (success: Bool, error: NSError!) -> Void in
//                if success {
//                    print("User follow successful: \(success)")
//                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                        sender.selected = true
//                        self.customizeBtn(.Follow)
//                    })
//                } else if error != nil{
//                    print("\nError followUser: \(error)")
//                }
//            })
        case BtnState.Unfollow.rawValue:
            print("Unfollow")
            // NewSDK
            appDel.rxTapglue.deleteConnection(toUserId: cellUser.id!, type: .Follow).subscribe({ (event) in
                switch event {
                case .Next(let element):
                    print(element)
                case .Error(let error):
                    self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                case .Completed:
                    print("Do the action")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        sender.selected = false
                        self.customizeBtn(.Unfollow)
                    })
                }
            }).addDisposableTo(self.appDel.disposeBag)
            
            // OldSDK
//            Tapglue.unfollowUser(cellUser, withCompletionBlock: { (success: Bool, error: NSError!) -> Void in
//                if success {
//                    print("User unfollow successful")
//                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                        sender.selected = false
//                        self.customizeBtn(.Unfollow)
//                    })
//                } else if error != nil{
//                    print("\nError unfollowUser: \(error)")
//                }
//            })
        case BtnState.Decline.rawValue:
            print("Decline")
            
            // NewSDK
            let connect = Connection(toUserId: cellUser.id!, type: .Friend, state: .Rejected)
            
            appDel.rxTapglue.createConnection(connect).subscribe({ (event) in
                switch event {
                case .Next( _):
                    print("Next")
                case .Error(let error):
                    self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                case .Completed:
                    print("Do the action")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        sender.selected = true
                        self.customizeBtn(.Pending)
                    })
                }
            }).addDisposableTo(self.appDel.disposeBag)
            
            // OldSDK
//            Tapglue.friendUser(cellUser, withState: TGConnectionState.Rejected, withCompletionBlock: { (success : Bool, error : NSError!) -> Void in
//                if success {
//                    print(success)
//                } else if error != nil{
//                    print("\nError friendUser: \(error)")
//                }
//            })
        default:
            print("default left")
        }
    }
    
    func connectRightBtnState(sender: UIButton){
        switch sender.tag {
        case BtnState.Friend.rawValue:
            print("Friend")
            
            // NewSDK
            let connect = Connection(toUserId: cellUser.id!, type: .Friend, state: .Pending)
            
            appDel.rxTapglue.createConnection(connect).subscribe({ (event) in
                switch event {
                case .Next( _):
                    print("Next")
                case .Error(let error):
                    self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                case .Completed:
                    print("Do the action")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        sender.selected = true
                        self.customizeBtn(.Pending)
                    })
                }
            }).addDisposableTo(self.appDel.disposeBag)
            
            // OldSDK
//            Tapglue.friendUser(cellUser, withState: TGConnectionState.Pending, withCompletionBlock: { (success : Bool, error : NSError!) -> Void in
//                if success {
//                    print("Do friendship: \(success)")
//                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                        sender.selected = true
//                        self.customizeBtn(.Pending)
//                    })
//                } else if error != nil{
//                    print("\nError friendUser: \(error)")
//                }
//            })
        case BtnState.Unfriend.rawValue:
            print("Unfriend")
            // NewSDK
            appDel.rxTapglue.deleteConnection(toUserId: cellUser.id!, type: .Friend).subscribe({ (event) in
                switch event {
                case .Next(let element):
                    print(element)
                case .Error(let error):
                    self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                case .Completed:
                    print("Do the action")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        sender.selected = false
                        self.customizeBtn(.Unfriend)
                    })
                }
            }).addDisposableTo(self.appDel.disposeBag)
            
            // OldSDK
//            Tapglue.unfriendUser(cellUser, withCompletionBlock: { (success: Bool,error: NSError!) -> Void in
//                if success {
//                    print("User unfriend successful")
//                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                        sender.selected = false
//                        self.customizeBtn(.Unfriend)
//                    })
//                } else if error != nil{
//                    print("\nError unfriendUser: \(error)")
//                }
//            })
        case BtnState.Pending.rawValue:
            print("Still Pending")
            
        case BtnState.Accept.rawValue:
            print("Accept")
            
            // NewSDK
            let connect = Connection(toUserId: cellUser.id!, type: .Friend, state: .Confirmed)
            
            appDel.rxTapglue.createConnection(connect).subscribe({ (event) in
                switch event {
                case .Next( _):
                    print("Next")
                case .Error(let error):
                    self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                case .Completed:
                    print("Do the action")
                }
            }).addDisposableTo(self.appDel.disposeBag)
            
            // OldSDK
//            Tapglue.friendUser(cellUser, withState: TGConnectionState.Confirmed, withCompletionBlock: { (success : Bool, error : NSError!) -> Void in
//                if success {
//                    print("Confirmed friendship: \(success)")
//                } else if error != nil{
//                    print("\nError friendUser: \(error)")
//                }
//            })
            
        default:
            print("default right")
        }
    }
    
    enum BtnState: Int {
        case Invite = 10
        case Follow = 20
        case Unfollow = 21
        case Friend = 30
        case Unfriend = 31
        case Pending = 40
        case Accept = 41
        case Decline = 42
    }
}
