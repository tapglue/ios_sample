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
    
    // Get the AppDelegate
    let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    @IBOutlet weak var notificationsTableView: UITableView!
    
    var checkmarkedActivities: [Bool] = []
    
    // Event arr
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
        
        // TODO: To use filtered activities you need first retrieveActivityWithType that is coming soon
        // Get all activities
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
        let storyboard = UIStoryboard(name: "PostDetail", bundle: nil)
        let pdVC =
            storyboard.instantiateViewControllerWithIdentifier("PostDetailViewController")
                as! PostDetailVC
        
        appDel.rxTapglue.retrievePost(id).subscribe { (event) in
            switch event {
            case .Next(let post):
                print("Next")
                pdVC.post = post
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Do the action")
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.navigationController!.pushViewController(pdVC, animated: true)
                })
            }
            }.addDisposableTo(self.appDel.disposeBag)
    }
    
    func goToUserByID(id: String) {
        let storyboard = UIStoryboard(name: "UserProfile", bundle: nil)
        let userProfileViewController = storyboard.instantiateViewControllerWithIdentifier("UserProfileViewController") as! UserProfileVC
        
        appDel.rxTapglue.retrieveUser(id).subscribe { (event) in
            switch event {
            case .Next(let usr):
                print("Next")
                userProfileViewController.userProfile = usr
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Do the action")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.navigationController?.pushViewController(userProfileViewController, animated: true)
                })
            }
        }.addDisposableTo(self.appDel.disposeBag)
    }
}

