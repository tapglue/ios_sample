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
    
    var activityFeed: [Activity] = []
    var posts: [Post] = []
    
    var postEditingText: String?
    var tempPost: Post?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        print("----- will Appear ----")
        
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
        
        // TO-DO: Check nil
        // UserImage
        if let profileImages = appDel.rxTapglue.currentUser?.images {
            self.userImageView.kf_setImageWithURL(NSURL(string: profileImages["profile"]!.url!)!)
        }
    }
    
    func getEventsAndPostsOfCurrentUser() {
        let currentUser = appDel.rxTapglue.currentUser!
        print(currentUser.id!)
        // NewSDK
        appDel.rxTapglue.retrieveActivitiesByUser(currentUser.id!).subscribe { (event) in
            switch event {
            case .Next(let activities):
                print("Next")
                print(activities)
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityFeed = activities
                    self.profileFeedTableView.reloadData()
                }
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Do the action")
            }
        }.addDisposableTo(self.appDel.disposeBag)
        
        // NewSDK
        appDel.rxTapglue.retrievePostsByUser(currentUser.id!).subscribe { (event) in
            switch event {
            case .Next(let posts):
                print("Next")
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.posts = posts
                    self.profileFeedTableView.reloadData()
                }
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
                case .Next( _):
//                    print(element)
                    print("element")
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

        }
        delete.backgroundColor = UIColor.redColor()
        return [delete, edit]
    }
}

