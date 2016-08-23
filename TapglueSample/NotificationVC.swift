//
//  NotificationVC.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 15/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue

class NotificationVC: UIViewController, UITableViewDelegate {
    
    let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    @IBOutlet weak var notificationsTableView: UITableView!
    
    var checkmarkedActivities: [Bool] = []
    
    var activityFeed: [Activity] = []
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(NotificationVC.loadNotificationFeed), forControlEvents: UIControlEvents.ValueChanged)
        self.notificationsTableView.addSubview(refreshControl)
        self.notificationsTableView.sendSubviewToBack(refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.loadNotificationFeed()
    }
    
    override func viewWillDisappear(animated: Bool) {
        tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
    func refresh(sender:AnyObject){
        self.loadNotificationFeed()
    }
    
    func loadNotificationFeed() {
        self.refreshControl?.beginRefreshing()
        
        // Get me related activities
        appDel.rxTapglue.retrieveMeFeed().subscribe { (event) in
            switch event {
            case .Next(let activities):
                print("Next")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    print(activities)
                    self.activityFeed = activities
                    self.notificationsTableView.reloadData()
                })
                self.refreshControl.endRefreshing()
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Do the action")
            }
        }.addDisposableTo(self.appDel.disposeBag)
    }
}

extension NotificationVC: UITableViewDataSource {
    // Mark: -TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(activityFeed.count)
        return activityFeed.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NotificationTableViewCell
                
        cell.configureCellWithEvent(activityFeed[indexPath.row])
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch activityFeed[indexPath.row].type! {
        case "tg_friend":
            goToUserByID(activityFeed[indexPath.row].userId!)
        case "tg_follow":
            goToUserByID(activityFeed[indexPath.row].userId!)
        case "tg_like":
            goToPostByID(activityFeed[indexPath.row].postId!)
        case "tg_comment":
            goToPostByID(activityFeed[indexPath.row].postId!)
        default:
            print("rest")
            
        }
        
    }
    
    func goToPostByID(id: String) {
        // Retrieve Post with ID
        appDel.rxTapglue.retrievePost(id).subscribe { (event) in
            switch event {
            case .Next(let post):
                print("Next")
                let storyboard = UIStoryboard(name: "PostDetail", bundle: nil)
                let pdVC =
                    storyboard.instantiateViewControllerWithIdentifier("PostDetailViewController")
                        as! PostDetailVC
                
                pdVC.post = post
                print("Post User: \(post.userId)")
                
                self.appDel.rxTapglue.retrieveUser(post.userId!).subscribe { (event) in
                    switch event {
                    case .Next(let usr):
                        print("Next")
                        
                        print("THE USER POST ID USERNAME: \(usr.username!)")
                        
                    case .Error(let error):
                        self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                    case .Completed:
                        print("Do the action")
                        self.navigationController?.pushViewController(pdVC, animated: true)
                        
                    }
                }.addDisposableTo(self.appDel.disposeBag)
                
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Do the action")
            }
        }.addDisposableTo(self.appDel.disposeBag)
    }
    
    func goToUserByID(id: String) {
        // Retrieve User with ID
        appDel.rxTapglue.retrieveUser(id).subscribe { (event) in
            switch event {
            case .Next(let usr):
                print("Next")
                let storyboard = UIStoryboard(name: "UserProfile", bundle: nil)
                let userProfileViewController = storyboard.instantiateViewControllerWithIdentifier("UserProfileViewController") as! UserProfileVC
                
                userProfileViewController.userProfile = usr
                
                self.navigationController?.pushViewController(userProfileViewController, animated: true)
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Do the action")
                
            }
        }.addDisposableTo(self.appDel.disposeBag)
    }
}

