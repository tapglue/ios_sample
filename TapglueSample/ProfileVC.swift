//
//  ProfileVC.swift
//  TapglueSample
//
//  Created by Onur Akpolat on 23.10.15.
//  Copyright © 2015 Tapglue. All rights reserved.
//

import UIKit
import Tapglue

class ProfileVC: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var friendsCountButton: UIButton!
    @IBOutlet weak var followerCountButton: UIButton!
    @IBOutlet weak var followingCountButton: UIButton!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userAboutLabel: UILabel!
    @IBOutlet weak var userFullnameLabel: UILabel!
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var feedSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var profileFeedTableView: UITableView!
    
    var events: [TGEvent] = []
    var posts: [TGPost] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        // Check for tapglue user
        if TGUser.currentUser() != nil {
            print(TGUser.currentUser())
            
            refreshTGUser()
            
            currentFriendsFollowerFollowingCount()
            
            getEventsAndPostsOfCurrentUser()
            
            let tapglueUser = TGUser.currentUser()
            
            self.userNameLabel.text = tapglueUser.username
            self.userFullnameLabel.text = tapglueUser.firstName + " " + tapglueUser.lastName
            let meta = tapglueUser.metadata as AnyObject
            self.userAboutLabel.text = String(meta.valueForKey("about")!)
            
            // UserImage
            var userImage = TGImage()
            userImage = TGUser.currentUser().images.valueForKey("profilePic") as! TGImage
            self.userImageView.downloadedFrom(link: userImage.url, contentMode: .ScaleAspectFill)
        } else {
            // Show loginVC if TGUser is nil
            self.navigationController?.performSegueWithIdentifier("loginSegue", sender: nil)
        }
        
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
    
    @IBAction func feedSegmentedChanged(sender: UISegmentedControl) {
        self.profileFeedTableView.reloadData()
    }
    
    func getEventsAndPostsOfCurrentUser() {
        Tapglue.retrieveEventsForCurrentUserWithCompletionBlock { (events: [AnyObject]!,error: NSError!) -> Void in
            if error != nil {
                print("Error happened\n")
                print(error)
            }
            else {
                self.events = events as! [TGEvent]
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.profileFeedTableView.reloadData()
                })
            }
        }
        Tapglue.retrievePostsForCurrentUserWithCompletionBlock { (posts: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                print("Error happened\n")
                print(error)
            }
            else {
                self.posts = posts as! [TGPost]
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.profileFeedTableView.reloadData()
                })
            }
        }
    }
    
    func currentFriendsFollowerFollowingCount() {
        friendsCountButton.setTitle(String(TGUser.currentUser().friendsCount) + " Friends", forState: .Normal)
        followerCountButton.setTitle(String(TGUser.currentUser().followersCount) + " Follower", forState: .Normal)
        followingCountButton.setTitle(String(TGUser.currentUser().followingCount) + " Following", forState: .Normal)
    }
    
    func refreshTGUser() {
        Tapglue.retrieveCurrentUserWithCompletionBlock { (user: TGUser!,error: NSError!) -> Void in
        }
    }
}

extension ProfileVC: UITableViewDataSource {
    // MARK: -TableView
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ProfileFeedTableViewCell
        
        switch feedSegmentedControl.selectedSegmentIndex {
            case 0:
                cell.configureCellWithEvent(events[indexPath.row])
            case 1:
                cell.configureCellWithPost(posts[indexPath.row])
            default: print("More then two segments")
        }
        
        return cell
    }
}
