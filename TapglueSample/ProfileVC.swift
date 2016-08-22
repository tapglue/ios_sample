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
    
    let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    @IBOutlet weak var friendsCountButton: UIButton!
    @IBOutlet weak var followerCountButton: UIButton!
    @IBOutlet weak var followingCountButton: UIButton!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userAboutLabel: UILabel!
    @IBOutlet weak var userFullnameLabel: UILabel!
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var feedSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var profileFeedTableView: UITableView!
    
    var activityFeed: [Activity] = []
    var posts: [Post] = []
    
    var postEditingText: String?
    var tempPost: Post?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        // Check for tapglue user
        if appDel.rxTapglue.currentUser != nil {
            
            refreshCurrentUser()
            
            showUserInfos()
        } else {
            // Show loginVC if User is nil
            self.navigationController?.performSegueWithIdentifier("loginSegue", sender: nil)
        }
    }
    
    // Friends, Follower and Following buttons
    @IBAction func friendsCountButtonPressed(sender: UIButton) {
        // Retrieve friends
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

    }
    
    @IBAction func followerCountButtonPressed(sender: UIButton) {
        // Retrieve followers
        appDel.rxTapglue.retrieveFollowers().subscribe { (event) in
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
        // Retrieve your follows
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
    }
    
    @IBAction func feedSegmentedChanged(sender: UISegmentedControl) {
        dispatch_async(dispatch_get_main_queue()) {
            self.profileFeedTableView.reloadData()
        }
    }
    
    func showUserInfos() {
        let usr = appDel.rxTapglue.currentUser!
        self.userNameLabel.text = usr.username
        self.userFullnameLabel.text = usr.firstName! + " " + usr.lastName!
        self.userAboutLabel.text = usr.about!
        
        if let profileImages = appDel.rxTapglue.currentUser?.images {
            self.userImageView.kf_setImageWithURL(NSURL(string: profileImages["profile"]!.url!)!)
        }
    }
    
    func getEventsAndPostsOfCurrentUser() {
        let currentUser = appDel.rxTapglue.currentUser!
        
        // Retrieve activities by user with ID
        appDel.rxTapglue.retrieveActivitiesByUser(currentUser.id!).subscribe { (event) in
            switch event {
            case .Next(let activities):
                print("Next")
                    self.activityFeed = activities
                    self.profileFeedTableView.reloadData()
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Do the action")
            }
        }.addDisposableTo(self.appDel.disposeBag)
        
        // Retrieve activities by user with ID
        appDel.rxTapglue.retrievePostsByUser(currentUser.id!).subscribe { (event) in
            switch event {
            case .Next(let posts):
                print("Next")
                    self.posts = posts
                    self.profileFeedTableView.reloadData()
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Do the action")
            }
        }.addDisposableTo(self.appDel.disposeBag)
        
    }
    
    func countFriendsFollowersAndFollowings() {
        friendsCountButton.setTitle(String(appDel.rxTapglue.currentUser!.friendCount!) + " Friends", forState: .Normal)
        followerCountButton.setTitle(String(appDel.rxTapglue.currentUser!.followerCount!) + " Follower", forState: .Normal)
        followingCountButton.setTitle(String(appDel.rxTapglue.currentUser!.followedCount!) + " Following", forState: .Normal)
    }
    
    func refreshCurrentUser() {
        print("---- Refreshing CURRENTUSER -----")
        
        // Refresh current User
        appDel.rxTapglue.refreshCurrentUser().subscribe { (event) in
            switch event {
            case .Next(let usr):
                print("Next")
                print("referesh \(usr) information of currentuser")
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Do the action")
                self.countFriendsFollowersAndFollowings()
                
                self.getEventsAndPostsOfCurrentUser()
            }
        }.addDisposableTo(self.appDel.disposeBag)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "postEditSegue" {
            let pVC: PostVC = segue.destinationViewController as! PostVC
            pVC.postBeginEditing = true
            pVC.tempPost = self.tempPost
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
                numberOfRows = activityFeed.count
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
                cell.configureCellWithEvent(activityFeed[indexPath.row])
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
                    // Retrieve post with postID
                    let postID = activityFeed[indexPath.row].postId!
                    appDel.rxTapglue.retrievePost(postID).subscribe({ (event) in
                        switch event {
                        case .Next(let post):
                            let storyboard = UIStoryboard(name: "PostDetail", bundle: nil)
                            let pdVC = storyboard.instantiateViewControllerWithIdentifier("PostDetailViewController")
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
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        switch feedSegmentedControl.selectedSegmentIndex {
            case 0:
                return false
            case 1:
                return true
            default: return false
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .Normal, title: "Edit") { action, index in
            
            self.tempPost = self.posts[indexPath.row]
            
            self.performSegueWithIdentifier("postEditSegue", sender: nil)
        }
        edit.backgroundColor = UIColor.lightGrayColor()
        
        let delete = UITableViewRowAction(style: .Destructive, title: "Delete") { action, index in
            
            // Delete post with postID
            self.appDel.rxTapglue.deletePost(self.posts[indexPath.row].id!).subscribe({ (event) in
                switch event {
                case .Next( _):
                    print("Next")
                case .Error(let error):
                    self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                case .Completed:
                    print("Do the action")
                    self.posts.removeAtIndex(indexPath.row)

                    
                    self.profileFeedTableView.reloadData()
                }
            }).addDisposableTo(self.appDel.disposeBag)

        }
        delete.backgroundColor = UIColor.redColor()
        return [delete, edit]
    }
}

