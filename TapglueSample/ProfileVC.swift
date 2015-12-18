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
        refreshTGUser()
        
        currentFriendsFollowerFollowingCount()
        
        getEventsAndPostsOfCurrentUser()
        
        profileFeedTableView.reloadData()
        
        
        let tapglueUser = TGUser.currentUser()
        
        let meta = tapglueUser.metadata as AnyObject
        self.userNameLabel.text = tapglueUser.username
        self.userFullnameLabel.text = tapglueUser.firstName + " " + tapglueUser.lastName
        self.userAboutLabel.text = String(meta.valueForKey("about")!)
        
        var userImage = TGImage()
        userImage = TGUser.currentUser().images.valueForKey("avatar") as! TGImage
        
        self.userImageView.image = UIImage(named: userImage.url)
    }
    
    // Friends, Follower and Following buttons
    @IBAction func friendsCountButtonPressed(sender: UIButton) {
        Tapglue.retrieveFriendsForCurrentUserWithCompletionBlock { (friends: [AnyObject]!, error: NSError!) -> Void in
            
            let usersViewController = self.storyboard?.instantiateViewControllerWithIdentifier("UsersViewController") as! UsersVC
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                usersViewController.users = friends as! [TGUser]
                self.navigationController?.pushViewController(usersViewController, animated: true)
            })
        }
    }
    @IBAction func followerCountButtonPressed(sender: UIButton) {
        Tapglue.retrieveFollowersForCurrentUserWithCompletionBlock { (followers: [AnyObject]!,error: NSError!) -> Void in
            
            let usersViewController = self.storyboard?.instantiateViewControllerWithIdentifier("UsersViewController") as! UsersVC
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                usersViewController.users = followers as! [TGUser]
                self.navigationController?.pushViewController(usersViewController, animated: true)
            })
        }
    }
    @IBAction func followingCountButtonPressed(sender: UIButton) {
        Tapglue.retrieveFollowsForCurrentUserWithCompletionBlock { (following: [AnyObject]!,error: NSError!) -> Void in
            
            let usersViewController = self.storyboard?.instantiateViewControllerWithIdentifier("UsersViewController") as! UsersVC
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                usersViewController.users = following as! [TGUser]
                self.navigationController?.pushViewController(usersViewController, animated: true)
            })
        }
    }
    
    
    
    @IBAction func feedSegmentedChanged(sender: UISegmentedControl) {
        self.profileFeedTableView.reloadData()
    }
    
    
        // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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
        // Configure the cell...
        cell.layoutMargins = UIEdgeInsetsZero
        
        switch feedSegmentedControl.selectedSegmentIndex {
        case 0:
            cell.configureCellWithEvent(events[indexPath.row])
        case 1:
            cell.configureCellWithPost(posts[indexPath.row])
        default: print("More then two segments")
        }
        
    
        return cell
    }
    
    
    func getEventsAndPostsOfCurrentUser() {
        Tapglue.retrieveEventsForCurrentUserWithCompletionBlock { (events: [AnyObject]!,error: NSError!) -> Void in
            if error != nil {
                print("Error happened\n")
                print(error)
            }
            else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.events = events as! [TGEvent]
                })
            }
        }
        Tapglue.retrievePostsForCurrentUserWithCompletionBlock { (posts: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                print("Error happened\n")
                print(error)
            }
            else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.posts = posts as! [TGPost]
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