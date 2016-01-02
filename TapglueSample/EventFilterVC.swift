//
//  EventFilterVC.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 16/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

//  Checked Default Array: will be initialized at NavigationController.


import UIKit

class EventFilterVC: UIViewController, UITableViewDelegate {
    
    let events: [String] = ["Likes", "Bookmarked", "Friend", "Follow"]
    let eventType: [String] = ["like_event", "bookmark_event", "tg_friend", "tg_follow"]
    
    var checked: [Bool] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        readChecked()
    }
    
    func readChecked()  {
        // get default checked arr
        let defaults = NSUserDefaults.standardUserDefaults()
        checked = defaults.objectForKey("checked") as! [Bool]
        print(checked)
    }
    
    // Back button pressed
    override func willMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            
            // Save checked to defaults
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(checked, forKey: "checked")
            defaults.synchronize()
        }
    }
}

extension EventFilterVC: UITableViewDataSource {
    // MARK: -TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! EventFilterTableViewCell
        
        cell.eventNameLabel.text = events[indexPath.row]
        
        if checked[indexPath.row] == false {
            cell.accessoryType = .None
        } else if checked[indexPath.row] == true {
            cell.accessoryType = .Checkmark
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell.accessoryType == .Checkmark{
                cell.accessoryType = .None
                checked[indexPath.row] = false
            } else{
                cell.accessoryType = .Checkmark
                checked[indexPath.row] = true
            }
        }
    }
}