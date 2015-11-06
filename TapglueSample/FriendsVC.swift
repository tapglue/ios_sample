//
//  FriendsVC.swift
//  TapglueSample
//
//  Created by Onur Akpolat on 05/11/15.
//  Copyright © 2015 Tapglue. All rights reserved.
//

import UIKit
import Tapglue

class FriendsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    // Tapglue users array
    var users: [TGUser] = []
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "loadFriends", forControlEvents: UIControlEvents.ValueChanged)
        self.friendsTableView.addSubview(refreshControl)
        self.friendsTableView.sendSubviewToBack(refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        self.loadFriends()
    }
    
    func refresh(sender:AnyObject)
    {
        self.loadFriends()
    }
    
    func loadFriends() {
        self.refreshControl?.beginRefreshing()
        Tapglue.retrieveFriendsForCurrentUserWithCompletionBlock { (users : [AnyObject]!, error : NSError!) -> Void in
            if users != nil && error == nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.users = users as! [TGUser]
                    self.friendsTableView.reloadData()
                })
            } else if error != nil{
                print("Error happened\n")
                print(error)
            }
            self.refreshControl?.endRefreshing()
        }
    }
    
    /*
    * TableView Methods
    */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UserTableViewCell
        let user = self.users[indexPath.row]
        cell.configureCellWithUser(user)
        
        return cell
    }
}