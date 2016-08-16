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
    
    // Get the AppDelegate
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
    
    var activities: [Activity] = []
    var posts: [Post] = []
    
    var postEditingText: String?
    var tempPost: Post?
    
    var currentUser: User!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser = appDel.rxTapglue.currentUser
    }
    
    override func viewWillAppear(animated: Bool) {
        // Check for tapglue user
        if currentUser != nil {
            refreshTGUser()
            
            countFriendsFollowersAndFollowings()
            
            getEventsAndPostsOfCurrentUser()
            
            let usr = currentUser
            
            self.userNameLabel.text = usr.username
            self.userFullnameLabel.text = usr.firstName! + " " + usr.lastName!
            
            // OldSDK TODO: Fix if about available
//            let meta = tapglueUser.metadata as AnyObject
//            self.userAboutLabel.text = String(meta.valueForKey("about")!)
            
            // OldSDK
//            // UserImage
//            var userImage = TGImage()
//            userImage = TGUser.currentUser().images.valueForKey("profilePic") as! TGImage
//            self.userImageView.kf_setImageWithURL(NSURL(string: userImage.url)!)
        } else {
            // Show loginVC if TGUser is nil
            self.navigationController?.performSegueWithIdentifier("loginSegue", sender: nil)
        }
        
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
//        Tapglue.retrieveFriendsForCurrentUserWithCompletionBlock { (friends: [AnyObject]!, error: NSError!) -> Void in
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
        
        //OldSDK
//        Tapglue.retrieveFollowersForCurrentUserWithCompletionBlock { (followers: [AnyObject]!,error: NSError!) -> Void in
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
//        Tapglue.retrieveFollowsForCurrentUserWithCompletionBlock { (following: [AnyObject]!,error: NSError!) -> Void in
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
    
    @IBAction func feedSegmentedChanged(sender: UISegmentedControl) {
        dispatch_async(dispatch_get_main_queue()) {
            self.profileFeedTableView.reloadData()
        }
    }
    
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
                    self.profileFeedTableView.reloadData()
                }
            }
        }.addDisposableTo(self.appDel.disposeBag)
        // OldSDK
//        Tapglue.retrieveEventsForCurrentUserWithCompletionBlock { (events: [AnyObject]!,error: NSError!) -> Void in
//            if error != nil {
//                print("\nError retrieveEventsForCurrentUser: \(error)")
//            }
//            else {
//                self.events = events as! [TGEvent]
//                
//                dispatch_async(dispatch_get_main_queue()) {
//                    self.profileFeedTableView.reloadData()
//                }
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
                    self.profileFeedTableView.reloadData()
                }
            }
        }.addDisposableTo(self.appDel.disposeBag)
        
        // OldSDK
//        Tapglue.retrievePostsForCurrentUserWithCompletionBlock { (posts: [AnyObject]!, error: NSError!) -> Void in
//            if error != nil {
//                print("\nError retrievePostsForCurrentUser: \(error)")
//            }
//            else {
//                self.posts = posts as! [TGPost]
//                
//                dispatch_async(dispatch_get_main_queue()) {
//                    self.profileFeedTableView.reloadData()
//                }
//            }
//        }
    }
    
    func countFriendsFollowersAndFollowings() {
        friendsCountButton.setTitle(String(currentUser.friendCount) + " Friends", forState: .Normal)
        followerCountButton.setTitle(String(currentUser.followedCount) + " Follower", forState: .Normal)
        followingCountButton.setTitle(String(currentUser.followerCount) + " Following", forState: .Normal)
    }
    
    func refreshTGUser() {
        currentUser = appDel.rxTapglue.currentUser
        
        // OldSDK
//        Tapglue.retrieveCurrentUserWithCompletionBlock { (user: TGUser!,error: NSError!) -> Void in
//        }
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
                numberOfRows = activities.count
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
                cell.configureCellWithEvent(activities[indexPath.row])
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
                
                // pass data
                pdVC.post = posts[indexPath.row]
                
                // tell the new controller to present itself
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
            // Passing TGPost
            self.tempPost = self.posts[indexPath.row]
            
            // Go to PostVC
            self.performSegueWithIdentifier("postEditSegue", sender: nil)
        }
        edit.backgroundColor = UIColor.lightGrayColor()
        
        let delete = UITableViewRowAction(style: .Destructive, title: "Delete") { action, index in
            
            // NewSDK
            self.appDel.rxTapglue.deletePost(self.posts[indexPath.row].id!).subscribe({ (event) in
                switch event {
                case .Next(let element):
                    print(element)
                case .Error(let error):
                    self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                case .Completed:
                    print("Do the action")
                    self.posts.removeAtIndex(indexPath.row)

                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.profileFeedTableView.reloadData()
                    })
                }
            }).addDisposableTo(self.appDel.disposeBag)
            
            // OldSDK
//            Tapglue.deletePostWithId(self.posts[indexPath.row].objectId, withCompletionBlock: { (success: Bool, error: NSError!) -> Void in
//                if error != nil {
//                    print("\nError deleteComment: \(error)")
//                }
//                else {
//                    print("\nSuccess: \(success)")
//                    self.posts.removeAtIndex(indexPath.row)
//                    
//                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                        self.profileFeedTableView.reloadData()
//                    })
//                }
//            })
        }
        delete.backgroundColor = UIColor.redColor()
        return [delete, edit]
    }
}

