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
    
    var activityFeed: [Activity] = []
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
        
        showUserInfos(userProfile!)
        
        countFriendsFollowsAndFollowings()
        
        getEventsAndPostsOfCurrentUser()
    }
    
    @IBAction func feedSegmentedChanged(sender: UISegmentedControl) {
        self.userProfileFeedTableView.reloadData()
    }
    
    // Friends, Follower and Following buttons
    @IBAction func friendsCountButtonPressed(sender: UIButton) {
        
        //NewSDK
        appDel.rxTapglue.retrieveFriendsForUserId(userProfile!.id!).subscribe { (event) in
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

    }
    
    @IBAction func followerCountButtonPressed(sender: UIButton) {
        
        //NewSDK
        appDel.rxTapglue.retrieveFollowersForUserId(userProfile!.id!).subscribe { (event) in
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
        
    }
    
    @IBAction func followingCountButtonPressed(sender: UIButton) {
        //NewSDK
        appDel.rxTapglue.retrieveFollowingsForUserId(userProfile!.id!).subscribe { (event) in
            switch event {
            case .Next(let usrs):
                print("Next")
                print("FollowingCount: \(usrs.count)")
                let storyboard = UIStoryboard(name: "Users", bundle: nil)
                let usersViewController = storyboard.instantiateViewControllerWithIdentifier("UsersViewController") as! UsersVC
                
                usersViewController.users = usrs
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.navigationController?.pushViewController(usersViewController, animated: true)
                })
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Do the action")
                
            }
        }.addDisposableTo(self.appDel.disposeBag)

    }
    
    // Fill user profile
    func showUserInfos(user: User){
        userFullnameLabel.text = user.firstName! + " " + user.lastName!
        userUsernameLabel.text = "@" + user.username!
        userAboutLabel.text = user.about!
        
        
        // TODO: Check nil
        // UserImage
        if let profileImages = user.images {
            self.userImageView.kf_setImageWithURL(NSURL(string: profileImages["profile"]!.url!)!)
        }
     }
    
    // Get events and posts for current user
    func getEventsAndPostsOfCurrentUser() {
        // NewSDK
        appDel.rxTapglue.retrieveActivitiesByUser(userProfile!.id!).subscribe { (event) in
            switch event {
            case .Next(let activities):
                print("Next")
                self.activityFeed = activities
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Do the action")
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.userProfileFeedTableView.reloadData()
                }
            }
        }.addDisposableTo(self.appDel.disposeBag)

        // NewSDK
        appDel.rxTapglue.retrievePostsByUser(userProfile!.id!).subscribe { (event) in
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
    }
    
    func countFriendsFollowsAndFollowings() {
        print("Friends: \(userProfile!.friendCount!)")
        print("Friends: \(userProfile!.followerCount!)")
        print("Friends: \(userProfile!.followedCount!)")
        friendsCountButton.setTitle(String(userProfile!.friendCount!) + " Friends", forState: .Normal)
        followerCountButton.setTitle(String(userProfile!.followerCount!) + " Follower", forState: .Normal)
        followingCountButton.setTitle(String(userProfile!.followedCount!) + " Following", forState: .Normal)
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
                numberOfRows = activityFeed.count
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
                cell.configureCellWithActivity(activityFeed[indexPath.row])
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