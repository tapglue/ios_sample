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
        // Retrieve friends with user ID
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
        // Retrieve followers with user ID
        appDel.rxTapglue.retrieveFollowersForUserId(userProfile!.id!).subscribe { (event) in
            switch event {
            case .Next(let usr):
                print("Next")
                let storyboard = UIStoryboard(name: "Users", bundle: nil)
                let usersViewController = storyboard.instantiateViewControllerWithIdentifier("UsersViewController") as! UsersVC
                
                usersViewController.users = usr
                
                self.navigationController?.pushViewController(usersViewController, animated: true)
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Do the action")
                
            }
        }.addDisposableTo(self.appDel.disposeBag)
        
    }
    
    @IBAction func followingCountButtonPressed(sender: UIButton) {
        // Retrieve follows with user ID
        appDel.rxTapglue.retrieveFollowingsForUserId(userProfile!.id!).subscribe { (event) in
            switch event {
            case .Next(let usrs):
                print("Next")
                print("FollowingCount: \(usrs.count)")
                let storyboard = UIStoryboard(name: "Users", bundle: nil)
                let usersViewController = storyboard.instantiateViewControllerWithIdentifier("UsersViewController") as! UsersVC
                
                usersViewController.users = usrs
                
                self.navigationController?.pushViewController(usersViewController, animated: true)
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Do the action")
                
            }
        }.addDisposableTo(self.appDel.disposeBag)
    }
    
    // Show user profile information
    func showUserInfos(user: User){
        userFullnameLabel.text = user.firstName! + " " + user.lastName!
        userUsernameLabel.text = "@" + user.username!
        userAboutLabel.text = user.about!
        
        if let profileImages = user.images {
            self.userImageView.kf_setImageWithURL(NSURL(string: profileImages["profile"]!.url!)!)
        }
     }
    
    // Get activities and posts for current user
    func getEventsAndPostsOfCurrentUser() {
        // Retrieve activities by user with ID
        appDel.rxTapglue.retrieveActivitiesByUser(userProfile!.id!).subscribe { (event) in
            switch event {
            case .Next(let activities):
                print("Next")
                self.activityFeed = activities
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Do the action")
                
                self.userProfileFeedTableView.reloadData()
            }
        }.addDisposableTo(self.appDel.disposeBag)

        // Retrieve posts by user with ID
        appDel.rxTapglue.retrievePostsByUser(userProfile!.id!).subscribe { (event) in
            switch event {
            case .Next(let posts):
                print("Next")
                self.posts = posts
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Do the action")
                
                self.userProfileFeedTableView.reloadData()
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
                if "tg_like" == activityFeed[indexPath.row].type! {
                    
                    //Fix: retrievePost does not give user
                    let postID = activityFeed[indexPath.row].postId!
                    appDel.rxTapglue.retrievePost(postID).subscribe({ (event) in
                        switch event {
                        case .Next(let post):
                            print("RetrievePostUser: \(post)")
                            let storyboard = UIStoryboard(name: "PostDetail", bundle: nil)
                            let pdVC =
                                storyboard.instantiateViewControllerWithIdentifier("PostDetailViewController")
                                    as! PostDetailVC
                            
                            pdVC.post = post
                            
                            self.navigationController!.pushViewController(pdVC, animated: true)
                        case .Error(let error):
                            self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                        case .Completed:
                            print("Do the action")
                        }
                    }).addDisposableTo(self.appDel.disposeBag)
                }
            case 1:
                let storyboard = UIStoryboard(name: "PostDetail", bundle: nil)
                let pdVC =
                    storyboard.instantiateViewControllerWithIdentifier("PostDetailViewController")
                    as! PostDetailVC
                
                pdVC.post = posts[indexPath.row]
                
                self.navigationController!.pushViewController(pdVC, animated: true)
            default: print("More then two segments")
        }
        
    }
}