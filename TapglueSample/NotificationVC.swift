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
    
    // Tapglue events array
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
        self.loadNotificationFeed()
    }
    
    func refresh(sender:AnyObject)
    {
        
        self.loadNotificationFeed()
    }
    
    func loadNotificationFeed() {
        self.refreshControl?.beginRefreshing()
        
        let types = ["like_event", "star_event", "heart_event", "tg_friend"]
        let query = TGQuery()
        query.addTypeIn(types)
        
        Tapglue.retrieveEventsForCurrentUserWithQuery(query) { (feed: [AnyObject]!,error: NSError!) -> Void in
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
        cell.configureCellWithEvent(currentUserEvents[indexPath.row])
        
        
        
        if currentUserEvents[indexPath.row].type == "tg_friend" {
            cell.eventNameLabel.text = "You are now friends with " + currentUserEvents[indexPath.row].target.user.username
            
            var userImage = TGImage()
            userImage = currentUserEvents[indexPath.row].target.user.images.valueForKey("avatar") as! TGImage
            cell.userImageView.image = UIImage(named: userImage.url)
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
