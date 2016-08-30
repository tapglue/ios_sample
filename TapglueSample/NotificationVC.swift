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
    var meFeed: [Activity] = []
    
    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var notificationSegmentedControl: UISegmentedControl!
    
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
    
    @IBAction func notificationSegmentedChanged(sender: UISegmentedControl) {
        dispatch_async(dispatch_get_main_queue()) {
            self.notificationsTableView.reloadData()
        }
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
                
                self.meFeed = activities
                self.notificationsTableView.reloadData()
                
                self.refreshControl.endRefreshing()
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Completed")
            }
            }.addDisposableTo(self.appDel.disposeBag)
        
        // Get me related activities
        appDel.rxTapglue.retrieveActivityFeed().subscribe { (event) in
            switch event {
            case .Next(let activities):
                
                self.activityFeed = activities
                self.notificationsTableView.reloadData()
                
                self.refreshControl.endRefreshing()
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Completed")
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
        var numberOfRows = 0
        
        switch notificationSegmentedControl.selectedSegmentIndex {
        case 0:
            numberOfRows = activityFeed.count
        case 1:
            numberOfRows = meFeed.count
        default: print("default")
        }
        return numberOfRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NotificationTableViewCell
        
        
        
        switch notificationSegmentedControl.selectedSegmentIndex {
        case 0:
            cell.configureCellWithEvent(activityFeed[indexPath.row])
        case 1:
            cell.configureCellWithEvent(meFeed[indexPath.row])
        default: print("default")
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        goToActivityFeedOrMeFeed(notificationSegmentedControl.selectedSegmentIndex, indexPath: indexPath)
    }
    
    func goToActivityFeedOrMeFeed(index: Int, indexPath: NSIndexPath) {
        switch index {
        case 0:
            switch activityFeed[indexPath.row].type! {
            case "tg_friend":
                goToUserByID(activityFeed[indexPath.row].targetUser!.id!)
            case "tg_follow":
                goToUserByID(activityFeed[indexPath.row].targetUser!.id!)
            case "tg_like":
                goToPostByID(activityFeed[indexPath.row].postId!)
            case "tg_comment":
                goToPostByID(activityFeed[indexPath.row].postId!)
            default:
                print("default")
                
            }
        case 1:
            switch meFeed[indexPath.row].type! {
            case "tg_friend":
                goToUserByID(meFeed[indexPath.row].userId!)
            case "tg_follow":
                goToUserByID(meFeed[indexPath.row].userId!)
            case "tg_like":
                goToPostByID(meFeed[indexPath.row].postId!)
            case "tg_comment":
                goToPostByID(meFeed[indexPath.row].postId!)
            default:
                print("rest")
                
            }
            
        default: print("default")
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
                
                self.appDel.rxTapglue.retrieveUser(post.userId!).subscribe { (event) in
                    switch event {
                    case .Next(let usr):
                        print("Next")
                        pdVC.post = post
                        pdVC.usr = usr
                        
                    case .Error(let error):
                        self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                    case .Completed:
                        print("Completed")
                        self.navigationController?.pushViewController(pdVC, animated: true)
                    }
                    }.addDisposableTo(self.appDel.disposeBag)
                
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Completed")
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
                print("Completed")
                
            }
            }.addDisposableTo(self.appDel.disposeBag)
    }
}

