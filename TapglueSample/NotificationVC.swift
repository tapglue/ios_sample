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
    
    var checkmarkedEvents: [Bool] = []
    
    // TGEvent arr
    var filteredEvents: [TGEvent] = []
    
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
        checkmarkedEvents = defaults.objectForKey("filterCheckmarks") as! [Bool]
        
        self.loadNotificationFeed()
        
        let filterImage = UIImage(named: "SortFilled")
        let filterButtonItem = UIBarButtonItem(image: filterImage, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(NotificationVC.filterButton(_:)))
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
        
        let allTypes = ["like_event", "bookmark_event", "tg_friend", "tg_follow", "tg_like"]
        
        var types = [String]()
        var count = 0
        for checked in checkmarkedEvents {
            if checked {
                types.append(allTypes[count])
               
            }
            count += 1
        }
        
        // Issue: Retrieve event types are not working proparly, if I use my custom types I get still tg_friend and tg_follow as my feed back
        
        Tapglue.retrieveEventsFeedForCurrentUserForEventTypes(types) { (feed: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                print("\nError retrieveEventsFeedForCurrentUserForEventTypes: \(error)")
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    print(feed)
                    self.filteredEvents = feed as! [TGEvent]
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
        print(filteredEvents.count)
        return filteredEvents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NotificationTableViewCell
                
        cell.configureCellWithEvent(filteredEvents[indexPath.row])
        
        return cell
    }

}

