//
//  NotificationVC.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 15/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue


class NotificationVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // TableView outlet
    @IBOutlet weak var notificationsTableView: UITableView!
    
    var checkedEvents: [Bool] = []
    
    // Tapglue events array
    var currentUserEvents: [TGEvent] = []
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewDidLoad")
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "loadNotificationFeed", forControlEvents: UIControlEvents.ValueChanged)
        self.notificationsTableView.addSubview(refreshControl)
        self.notificationsTableView.sendSubviewToBack(refreshControl)
        

    }
    
    override func viewWillAppear(animated: Bool) {
        print("viewWillAppear")

        let defaults = NSUserDefaults.standardUserDefaults()
        checkedEvents = defaults.objectForKey("checked") as! [Bool]
        print(checkedEvents)
        
        self.loadNotificationFeed()
        
        let filterImage = UIImage(named: "FilterFilled")
        let filterButtonItem = UIBarButtonItem(image: filterImage, style: UIBarButtonItemStyle.Plain, target: self, action: "filterButton:") //Use a selector
//        filterButtonItem.tintColor = UIColor.darkGrayColor()
        tabBarController?.navigationItem.rightBarButtonItem = filterButtonItem
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        print("viewDidAppear")
        
        
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
                print("Error happened\n")
                print(error)
            }
            else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.currentUserEvents = feed as! [TGEvent]
                    self.notificationsTableView.reloadData()
                })
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func filterButton(sender:AnyObject){
        
        print("BarButtonItemPressed")
        
        // Show loginVC if no user
        self.performSegueWithIdentifier("filterSegue", sender: nil)
    }

    
    
    /*
    * TableView Methods
    */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentUserEvents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NotificationTableViewCell
        
        cell.userImageView.image = nil
        
        print(currentUserEvents[indexPath.row].type)
        
        if currentUserEvents[indexPath.row].type == "tg_friend" {
            cell.configureCellForTypeTGFriend(currentUserEvents[indexPath.row])
        } else {
            cell.configureCellWithEvent(currentUserEvents[indexPath.row])
        }
        
        return cell
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
