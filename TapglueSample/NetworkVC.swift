//
//  NetworkVC.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 21/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue

class NetworkVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating  {
    
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    var users: [TGUser] = []
    var resultSearchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.friendsTableView.dataSource = self
        self.friendsTableView.delegate = self
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            self.friendsTableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        // Reload the table
        self.friendsTableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.resultSearchController.searchBar.hidden = false;
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.resultSearchController.searchBar.hidden = true;
        self.resultSearchController.active = false;
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NetworkUserTableViewCell
        let user = self.users[indexPath.row]
        cell.configureCellWithUser(user)
        return cell
        
    }
    
    /*
    * Searchbar Methods
    */
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        
        if (searchController.searchBar.text?.characters.count > 2) {
            Tapglue.searchUsersWithTerm(searchController.searchBar.text) { (users: [AnyObject]!, error: NSError!) -> Void in
                if users != nil && error == nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.users.removeAll(keepCapacity: false)
                        self.users = users as! [TGUser]
                        self.friendsTableView.reloadData()
                    })
                } else if error != nil{
                    print("Error happened\n")
                    print(error)
                }
            }
        } else {
            users.removeAll(keepCapacity: false)
            self.friendsTableView.reloadData()
        }
        
        if !searchController.active {
            users.removeAll(keepCapacity: false)
            self.friendsTableView.reloadData()
        }
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
