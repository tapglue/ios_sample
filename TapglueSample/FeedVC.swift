////
////  ActivityVC.swift
////  TapglueSample
////
////  Created by Onur Akpolat on 23.10.15.
////  Copyright © 2015 Tapglue. All rights reserved.
////
//
//import UIKit
//import Tapglue
//
//class FeedVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
//    
//    @IBOutlet weak var activityTableView: UITableView!
//    
//    // Tapglue events array
//    var events: [TGEvent] = []
//    
//    var refreshControl: UIRefreshControl!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        activityTableView.delegate = self
//        activityTableView.dataSource = self
//        
//        self.refreshControl = UIRefreshControl()
//        self.refreshControl.addTarget(self, action: "loadFriendsActivityFeed", forControlEvents: UIControlEvents.ValueChanged)
//        self.activityTableView.addSubview(refreshControl)
//        self.activityTableView.sendSubviewToBack(refreshControl)
//    }
//    
//    override func viewWillAppear(animated: Bool) {
//        self.refreshControl?.beginRefreshing()
//        self.loadFriendsActivityFeed()
//    }
//    
//    func refresh(sender:AnyObject)
//    {
//        self.refreshControl?.beginRefreshing()
//        self.loadFriendsActivityFeed()
//    }
//    
//    func loadFriendsActivityFeed() {
//        Tapglue.retrieveNewsFeedForCurrentUserWithCompletionBlock { (posts : [AnyObject]!, feed : [AnyObject]!, error : NSError!) -> Void in
//            if error != nil {
//                print("Error happened\n")
//                print(error)
//            }
//            else {
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    self.events = feed as! [TGEvent]
//                    self.activityTableView.reloadData()
//                })
//                self.refreshControl.endRefreshing()
//            }
//        }
//    }
//    
//    /*
//    * TableView Methods
//    */
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.events.count
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! EventTableViewCell
//        let event = self.events[indexPath.row]
//        cell.configureCellWithEvent(event)
//        
//        return cell
//    }
//}