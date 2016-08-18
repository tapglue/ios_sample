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
        
        refreshTGUser()
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
            self.userAboutLabel.text = usr.about!
            
            // TO-DO: Check nil
            // UserImage
            let profileImage = appDel.rxTapglue.currentUser?.images!["profile"]
            self.userImageView.kf_setImageWithURL(NSURL(string: profileImage!.url!)!)
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
    
    func getEventsAndPostsOfCurrentUser() {
        let currentUserID = appDel.rxTapglue.currentUser?.id!
        
        // NewSDK
        appDel.rxTapglue.retrieveActivitiesByUser(currentUserID!).subscribe { (event) in
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
        
        // NewSDK
        appDel.rxTapglue.retrievePostsByUser(currentUserID!).subscribe { (event) in
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
        
    }
    
    func countFriendsFollowersAndFollowings() {
        friendsCountButton.setTitle(String(currentUser.friendCount!) + " Friends", forState: .Normal)
        followerCountButton.setTitle(String(currentUser.followerCount!) + " Follower", forState: .Normal)
        followingCountButton.setTitle(String(currentUser.followedCount!) + " Following", forState: .Normal)
    }
    
    func refreshTGUser() {
        currentUser = appDel.rxTapglue.currentUser
        
        appDel.rxTapglue.retrieveUser(currentUser.id!).subscribe { (event) in
            switch event {
            case .Next(let usr):
                print("Next")
                print("retrieve user information of currentuser")
//                self.currentUser = usr
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Do the action")
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

        }
        delete.backgroundColor = UIColor.redColor()
        return [delete, edit]
    }
}

