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
    
    var userProfile: TGUser?
    
    var events: [TGEvent] = []
    var posts: [TGPost] = []
    
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
    }
    
    override func viewWillAppear(animated: Bool) {
        showUserInformation(userProfile!)
        
        currentFriendsFollowerFollowingCount()
        
        getEventsAndPostsOfCurrentUser()
    }
    
    @IBAction func feedSegmentedChanged(sender: UISegmentedControl) {
        self.userProfileFeedTableView.reloadData()
    }
    
    // Friends, Follower and Following buttons
    @IBAction func friendsCountButtonPressed(sender: UIButton) {
        Tapglue.retrieveFriendsForCurrentUserWithCompletionBlock { (friends: [AnyObject]!, error: NSError!) -> Void in
            let usersViewController = self.storyboard?.instantiateViewControllerWithIdentifier("UsersViewController") as! UsersVC
            
            usersViewController.users = friends as! [TGUser]
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.navigationController?.pushViewController(usersViewController, animated: true)
            })
        }
    }
    
    @IBAction func followerCountButtonPressed(sender: UIButton) {
        Tapglue.retrieveFollowersForCurrentUserWithCompletionBlock { (followers: [AnyObject]!,error: NSError!) -> Void in
            let usersViewController = self.storyboard?.instantiateViewControllerWithIdentifier("UsersViewController") as! UsersVC
            
            usersViewController.users = followers as! [TGUser]
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.navigationController?.pushViewController(usersViewController, animated: true)
            })
        }
    }
    
    @IBAction func followingCountButtonPressed(sender: UIButton) {
        Tapglue.retrieveFollowsForCurrentUserWithCompletionBlock { (following: [AnyObject]!,error: NSError!) -> Void in
            let usersViewController = self.storyboard?.instantiateViewControllerWithIdentifier("UsersViewController") as! UsersVC
            
            usersViewController.users = following as! [TGUser]
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.navigationController?.pushViewController(usersViewController, animated: true)
            })
        }
    }
    
    // Fill user profile
    func showUserInformation(user: TGUser){
        userFullnameLabel.text = user.firstName + " " + user.lastName
        userUsernameLabel.text = user.username
        
        let meta = user.metadata as AnyObject
        userAboutLabel.text = String(meta.valueForKey("about")!)
        
        var userImage = TGImage()
        userImage = TGUser.currentUser().images.valueForKey("profilePic") as! TGImage
        self.userImageView.kf_setImageWithURL(NSURL(string: userImage.url)!)
     }
    
    // Get events and posts for current user
    func getEventsAndPostsOfCurrentUser() {
        Tapglue.retrieveEventsForUser(userProfile) { (events: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                print("\nError retrieveEventsForUser: \(error)")
            } else {
                self.events = events as! [TGEvent]
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.userProfileFeedTableView.reloadData()
                })
            }
        }

        Tapglue.retrievePostsForUser(userProfile) { (posts: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                print("\nError retrievePostsForUser: \(error)")
            }
            else {
                self.posts = posts as! [TGPost]
    
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.userProfileFeedTableView.reloadData()
                })
            }
        }
    }
    
    func currentFriendsFollowerFollowingCount() {
        friendsCountButton.setTitle(String(TGUser.currentUser().friendsCount) + " Friends", forState: .Normal)
        followerCountButton.setTitle(String(TGUser.currentUser().followersCount) + " Follower", forState: .Normal)
        followingCountButton.setTitle(String(TGUser.currentUser().followingCount) + " Following", forState: .Normal)
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
                numberOfRows = events.count
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
                cell.configureCellWithEvent(events[indexPath.row])
            case 1:
                cell.configureCellWithPost(posts[indexPath.row])
            default: print("More then two segments")
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let pdVC =
        self.storyboard!.instantiateViewControllerWithIdentifier("PostDetailViewController")
            as! PostDetailVC
        
        // pass data to sub-viewcontroller
        pdVC.post = posts[indexPath.row]
        
        // tell the new controller to present itself
        self.navigationController!.pushViewController(pdVC, animated: true)
    }
}