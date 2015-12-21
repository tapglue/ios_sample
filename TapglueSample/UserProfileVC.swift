//
//  UserProfileVC.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 18/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue

class UserProfileVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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

        // Do any additional setup after loading the view.
        

    }
    override func viewWillAppear(animated: Bool) {
        showUserInformation(userProfile!)
        
        currentFriendsFollowerFollowingCount()
        
        getEventsAndPostsOfCurrentUser()
        
        print(posts.count)
        print(events.count)
        userProfileFeedTableView.reloadData()
    }
    
    @IBAction func feedSegmentedChanged(sender: UISegmentedControl) {
        self.userProfileFeedTableView.reloadData()
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UserProfileTableViewCell
        
        // Configure the cell...
        
        switch feedSegmentedControl.selectedSegmentIndex {
        case 0:
            cell.configureCellWithEvent(events[indexPath.row])
        case 1:
            cell.configureCellWithPost(posts[indexPath.row])
        default: print("More then two segments")
        }
        
        return cell
    }
    
    
    // Fill UserProfileVC with user information
    func showUserInformation(user: TGUser){
        userFullnameLabel.text = user.firstName + " " + user.lastName
        userUsernameLabel.text = user.username
        
        let meta = user.metadata as AnyObject
        userAboutLabel.text = String(meta.valueForKey("about")!)
        
        var userImage = TGImage()
        userImage = TGUser.currentUser().images.valueForKey("avatar") as! TGImage
        self.userImageView.image = UIImage(named: userImage.url)
     }
    
    // Custom Methods
    func getEventsAndPostsOfCurrentUser() {

        Tapglue.retrieveEventsForUser(userProfile) { (events: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                print("Error happened\n")
                print(error)
            }
            else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.events = events as! [TGEvent]
                    print(self.events)
                })
            }
        }

        Tapglue.retrievePostsForUser(userProfile) { (posts: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                print("Error happened\n")
                print(error)
            }
            else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.posts = posts as! [TGPost]
                    print(self.posts)
                })
            }
        }
    }
    
    func currentFriendsFollowerFollowingCount() {
        friendsCountButton.setTitle(String(TGUser.currentUser().friendsCount) + " Friends", forState: .Normal)
        followerCountButton.setTitle(String(TGUser.currentUser().followersCount) + " Follower", forState: .Normal)
        followingCountButton.setTitle(String(TGUser.currentUser().followingCount) + " Following", forState: .Normal)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
