//
//  MeVC.swift
//  TapglueSample
//
//  Created by Onur Akpolat on 23.10.15.
//  Copyright © 2015 Tapglue. All rights reserved.
//

import UIKit
import Tapglue

class MeVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // TableView outlet
    @IBOutlet weak var activityTableView: UITableView!
    
    // Tapglue events array
    var profileEvents: [TGEvent] = []
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityTableView.delegate = self
        activityTableView.dataSource = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "loadMyActivityFeed", forControlEvents: UIControlEvents.ValueChanged)
        self.activityTableView.addSubview(refreshControl)
        self.activityTableView.sendSubviewToBack(refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.loadMyActivityFeed()
    }
    
    func refresh(sender:AnyObject)
    {
        
        self.loadMyActivityFeed()
    }
    
    func loadMyActivityFeed() {
        self.refreshControl?.beginRefreshing()
        Tapglue.retrieveEventsForCurrentUserWithCompletionBlock { (feed : [AnyObject]!, error : NSError!) -> Void in
            if error != nil {
                print("Error happened\n")
                print(error)
            }
            else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.profileEvents = feed as! [TGEvent]
                    self.activityTableView.reloadData()
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
        return self.profileEvents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! EventTableViewCell
        let event = self.profileEvents[indexPath.row]
        cell.configureCellWithEvent(event)
        
        return cell
    }
}