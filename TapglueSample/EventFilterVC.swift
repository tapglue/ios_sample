//
//  EventFilterVC.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 16/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

//  Checked Default Array: will be initialized at NavigationController.


import UIKit

class EventFilterVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let events: [String] = ["Likes", "Bookmarked", "Friend"]
    let eventType: [String] = ["like_event", "bookmark_event", "tg_friend"]
    
    var checked: [Bool] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    override func viewWillAppear(animated: Bool) {
        readChecked()
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.events.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! EventFilterTableViewCell
        
        // Configure the cell...
        cell.eventNameLabel.text = events[indexPath.row]
        
        if checked[indexPath.row] == false {
            
            cell.accessoryType = .None
        }
        else if checked[indexPath.row] == true {
            
            cell.accessoryType = .Checkmark
        }
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell.accessoryType == .Checkmark
            {
                cell.accessoryType = .None
                checked[indexPath.row] = false
            }
            else
            {
                cell.accessoryType = .Checkmark
                checked[indexPath.row] = true
            }
        }
    }
    
    func readChecked()  {
        // get default checked array
        let defaults = NSUserDefaults.standardUserDefaults()
        checked = defaults.objectForKey("checked") as! [Bool]
        print(checked)
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
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            // "Back button pressed"
            // Save checked to defaults
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(checked, forKey: "checked")
            defaults.synchronize()

        }
    }
}
