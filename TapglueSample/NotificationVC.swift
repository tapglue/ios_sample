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
    var filteredActivity: [Activity] = []
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(NotificationVC.loadNotificationFeed), forControlEvents: UIControlEvents.ValueChanged)
        self.notificationsTableView.addSubview(refreshControl)
        self.notificationsTableView.sendSubviewToBack(refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        let defaults = NSUserDefaults.standardUserDefaults()
        checkmarkedActivities = defaults.objectForKey("filterCheckmarks") as! [Bool]
        
        self.loadNotificationFeed()
        
        // TODO: Turned off filterNotifcationsByTypeButton
//        let filterImage = UIImage(named: "SortFilled")
//        let filterButtonItem = UIBarButtonItem(image: filterImage, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(NotificationVC.filterButton(_:)))
//        tabBarController?.navigationItem.rightBarButtonItem = filterButtonItem
    }
    
    override func viewWillDisappear(animated: Bool) {
        tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
    func refresh(sender:AnyObject){
        self.loadNotificationFeed()
    }
    
    func loadNotificationFeed() {
        self.refreshControl?.beginRefreshing()
        
        let allTypes = ["like_event", "bookmark_event", "tg_friend", "tg_follow", "tg_like"]
        
        var types = [String]()
        var count = 0
        for checked in checkmarkedActivities {
            if checked {
                types.append(allTypes[count])
               
            }
            count += 1
        }
        
        // Issue: Retrieve event types are not working proparly, if I use my custom types I get still tg_friend and tg_follow as my feed back???
        
        // TODO: To use filtered activities you need first retrieveActivityWithType that is coming soon
        // Get all activities
        appDel.rxTapglue.retrieveActivityFeed().subscribe { (event) in
            switch event {
            case .Next(let activities):
                print("Next")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    print(activities)
                    self.filteredActivity = activities
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
    
    func filterButton(sender:AnyObject){
        // Show filterVC
        self.performSegueWithIdentifier("filterSegue", sender: nil)
    }
}

extension NotificationVC: UITableViewDataSource {
    // Mark: -TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(filteredActivity.count)
        return filteredActivity.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NotificationTableViewCell
                
        cell.configureCellWithEvent(filteredActivity[indexPath.row])
        
        return cell
    }

}

