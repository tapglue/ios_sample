//
//  HomeVC.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 14/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue

class HomeVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var homeTableView: UITableView!
    
    
    // Tapglue events array
    var events: [TGEvent] = []
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "loadFriendsActivityFeed:", forControlEvents: UIControlEvents.ValueChanged)
        self.homeTableView.addSubview(refreshControl)
        self.homeTableView.sendSubviewToBack(refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.refreshControl?.beginRefreshing()
        self.loadFriendsActivityFeed()
    }
    
    func refresh(sender:AnyObject)
    {
        self.refreshControl?.beginRefreshing()
        self.loadFriendsActivityFeed()
    }
    
    func loadFriendsActivityFeed() {
        Tapglue.retrieveNewsFeedForCurrentUserWithCompletionBlock { (posts : [AnyObject]!, feed : [AnyObject]!, error : NSError!) -> Void in
            if error != nil {
                print("Error happened\n")
                print(error)
            }
            else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.events = feed as! [TGEvent]
                    self.homeTableView.reloadData()
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
        return self.events.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! EventTableViewCell
        let event = self.events[indexPath.row]
        cell.configureCellWithEvent(event)
        
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
