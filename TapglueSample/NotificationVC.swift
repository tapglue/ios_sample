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
    
    @IBOutlet weak var notificationsTableView: UITableView!
    
    var checkedEvents: [Bool] = []
    
    // TGEvent arr
    var currentUserEvents: [TGEvent] = []
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "loadNotificationFeed", forControlEvents: UIControlEvents.ValueChanged)
        self.notificationsTableView.addSubview(refreshControl)
        self.notificationsTableView.sendSubviewToBack(refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {

        let defaults = NSUserDefaults.standardUserDefaults()
        checkedEvents = defaults.objectForKey("checked") as! [Bool]
        print(checkedEvents)
        
        self.loadNotificationFeed()
        
        let filterImage = UIImage(named: "FilterFilled")
        let filterButtonItem = UIBarButtonItem(image: filterImage, style: UIBarButtonItemStyle.Plain, target: self, action: "filterButton:") //Use a selector

        tabBarController?.navigationItem.rightBarButtonItem = filterButtonItem
    }
    
    override func viewWillDisappear(animated: Bool) {
        tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
    func refresh(sender:AnyObject){
        self.loadNotificationFeed()
    }
    
    func loadNotificationFeed() {
        self.refreshControl?.beginRefreshing()
        
        let allTypes = ["like_event", "bookmark_event", "tg_friend", "tg_follow"]
        
        var types = [String]()
        var count = 0
        for checked in checkedEvents {
            if checked {
                types.append(allTypes[count])
               
            }
            count++
        }
        
        Tapglue.retrieveEventsFeedForCurrentUserForEventTypes(types) { (feed: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                print("\nError retrieveEventsFeedForCurrentUserForEventTypes: \(error)")
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.currentUserEvents = feed as! [TGEvent]
                    self.notificationsTableView.reloadData()
                })
                self.refreshControl.endRefreshing()
            }
        }
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
        return currentUserEvents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NotificationTableViewCell
        
        cell.userImageView.image = nil
        
        if currentUserEvents[indexPath.row].type == "tg_friend" {
            cell.configureCellForTypeTGFriend(currentUserEvents[indexPath.row])
        } else {
            cell.configureCellWithEvent(currentUserEvents[indexPath.row])
        }
        
        return cell
    }

}
