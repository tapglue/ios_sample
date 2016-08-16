//
//  UserProfileVC.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 18/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue

class UserProfileVC: UIViewController, UITableViewDelegate {
    
    // Get the AppDelegate
    let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    var userProfile: User?
    
    var activities: [Activity] = []
    var posts: [Post] = []
    
    @IBOutlet weak var feedSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var friendsCountButton: UIButton!
    @IBOutlet weak var followerCountButton: UIButton!
    @IBOutlet weak var followingCountButton: UIButton!
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userFullnameLabel: UILabel!
    @IBOutlet weak var userUsernameLabel: UILabel!
    @IBOutlet weak var userAboutLabel: UILabel!
    
    @IBOutlet weak var userProfileFeedTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        showUserInformation(userProfile!)
        
        coutFriendsFollowsAndFollowings()
        
        getEventsAndPostsOfCurrentUser()
    }
    
    @IBAction func feedSegmentedChanged(sender: UISegmentedControl) {
        self.userProfileFeedTableView.reloadData()
    }
    
    // Friends, Follower and Following buttons
    @IBAction func friendsCountButtonPressed(sender: UIButton) {
        
        //NewSDK
        appDel.rxTapglue.retrieveFriends().subscribe { (event) in
            switch event {
            case .Next(let usr):
                print("Next")
                let storyboard = UIStoryboard(name: "Users", bundle: nil)
                let usersViewController = storyboard.instantiateViewControllerWithIdentifier("UsersViewController") as! UsersVC
                
                usersViewController.users = usr
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.navigationController?.pushViewController(usersViewController, animated: true)
                })
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Do the action")
                
            }
        }.addDisposableTo(self.appDel.disposeBag)
        
        // OldSDK
//        Tapglue.retrieveFriendsForUser(userProfile) { (friends: [AnyObject]!, error: NSError!) -> Void in
//            let storyboard = UIStoryboard(name: "Users", bundle: nil)
//            let usersViewController = storyboard.instantiateViewControllerWithIdentifier("UsersViewController") as! UsersVC
//            
//            usersViewController.users = friends as! [TGUser]
//            
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                self.navigationController?.pushViewController(usersViewController, animated: true)
//            })
//        }
    }
    
    @IBAction func followerCountButtonPressed(sender: UIButton) {
        
        //NewSDK
        appDel.rxTapglue.retrieveFollowers().subscribe { (event) in
            switch event {
            case .Next(let usr):
                print("Next")
                let storyboard = UIStoryboard(name: "Users", bundle: nil)
                let usersViewController = storyboard.instantiateViewControllerWithIdentifier("UsersViewController") as! UsersVC
                
                usersViewController.users = usr
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.navigationController?.pushViewController(usersViewController, animated: true)
                })
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Do the action")
                
            }
        }.addDisposableTo(self.appDel.disposeBag)
        
        // OldSDK
//        Tapglue.retrieveFollowersForUser(userProfile) { (followers: [AnyObject]!, error: NSError!) -> Void in
//            let storyboard = UIStoryboard(name: "Users", bundle: nil)
//            let usersViewController = storyboard.instantiateViewControllerWithIdentifier("UsersViewController") as! UsersVC
//            
//            usersViewController.users = followers as! [TGUser]
//            
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                self.navigationController?.pushViewController(usersViewController, animated: true)
//            })
//        }
    }
    
    @IBAction func followingCountButtonPressed(sender: UIButton) {
        //NewSDK
        appDel.rxTapglue.retrieveFollowings().subscribe { (event) in
            switch event {
            case .Next(let usr):
                print("Next")
                let storyboard = UIStoryboard(name: "Users", bundle: nil)
                let usersViewController = storyboard.instantiateViewControllerWithIdentifier("UsersViewController") as! UsersVC
                
                usersViewController.users = usr
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.navigationController?.pushViewController(usersViewController, animated: true)
                })
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Do the action")
                
            }
        }.addDisposableTo(self.appDel.disposeBag)
        
        // OldSDK
//        Tapglue.retrieveFollowsForUser(userProfile) { (following: [AnyObject]!, error: NSError!) -> Void in
//            let storyboard = UIStoryboard(name: "Users", bundle: nil)
//            let usersViewController = storyboard.instantiateViewControllerWithIdentifier("UsersViewController") as! UsersVC
//            
//            usersViewController.users = following as! [TGUser]
//            
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                self.navigationController?.pushViewController(usersViewController, animated: true)
//            })
//        }
    }
    
    // Fill user profile
    func showUserInformation(user: User){
        userFullnameLabel.text = user.firstName! + " " + user.lastName!
        userUsernameLabel.text = "@" + user.username!
        
        //OldSDK
//        let meta = user.metadata as AnyObject
//        userAboutLabel.text = String(meta.valueForKey("about")!)
//        
//        var userImage = TGImage()
//        userImage = self.userProfile!.images.valueForKey("profilePic") as! TGImage
//        self.userImageView.kf_setImageWithURL(NSURL(string: userImage.url)!)
     }
    
    // Get events and posts for current user
    func getEventsAndPostsOfCurrentUser() {
        // NewSDK
        appDel.rxTapglue.retrieveActivityFeed().subscribe { (event) in
            switch event {
            case .Next(let activi):
                print("Next")
                self.activities = activi
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Do the action")
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.userProfileFeedTableView.reloadData()
                }
            }
        }.addDisposableTo(self.appDel.disposeBag)
        
        //Old SDK
//        Tapglue.retrieveEventsForUser(userProfile) { (events: [AnyObject]!, error: NSError!) -> Void in
//            if error != nil {
//                print("\nError retrieveEventsForUser: \(error)")
//            } else {
//                self.events = events as! [TGEvent]
//                
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    self.userProfileFeedTableView.reloadData()
//                })
//            }
//        }
        // NewSDK
        appDel.rxTapglue.retrievePostFeed().subscribe { (event) in
            switch event {
            case .Next(let posts):
                print("Next")
                self.posts = posts
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Do the action")
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.userProfileFeedTableView.reloadData()
                }
            }
        }.addDisposableTo(self.appDel.disposeBag)
        
        // OldSDK
//        Tapglue.retrievePostsForUser(userProfile) { (posts: [AnyObject]!, error: NSError!) -> Void in
//            if error != nil {
//                print("\nError retrievePostsForUser: \(error)")
//            }
//            else {
//                self.posts = posts as! [TGPost]
//    
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    self.userProfileFeedTableView.reloadData()
//                })
//            }
//        }
    }
    
    func coutFriendsFollowsAndFollowings() {
        let friendsCount = String(userProfile?.friendCount)
        let followersCount = String(userProfile?.followerCount)
        let followingCount = String(userProfile?.followedCount)
        
        friendsCountButton.setTitle(friendsCount + " Friends", forState: .Normal)
        followerCountButton.setTitle(followersCount + " Follower", forState: .Normal)
        followingCountButton.setTitle(followingCount + " Following", forState: .Normal)
    }
}

extension UserProfileVC: UITableViewDataSource {
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        
        switch feedSegmentedControl.selectedSegmentIndex {
            case 0:
                numberOfRows = activities.count
            case 1:
                numberOfRows = posts.count
            default: print("More then two segments")
        }
        
        return numberOfRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UserProfileTableViewCell
        
        switch feedSegmentedControl.selectedSegmentIndex {
            case 0:
                cell.configureCellWithActivity(activities[indexPath.row])
            case 1:
                cell.configureCellWithPost(posts[indexPath.row])
            default: print("More then two segments")
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch feedSegmentedControl.selectedSegmentIndex {
            case 0:
                print("Activity segment")
            case 1:
                let storyboard = UIStoryboard(name: "PostDetail", bundle: nil)
                let pdVC =
                    storyboard.instantiateViewControllerWithIdentifier("PostDetailViewController")
                    as! PostDetailVC
                
                // pass data to sub-viewcontroller
                pdVC.post = posts[indexPath.row]
                
                // tell the new controller to present itself
                self.navigationController!.pushViewController(pdVC, animated: true)
            default: print("More then two segments")
        }
        
    }
}