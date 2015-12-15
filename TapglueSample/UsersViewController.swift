//
//  UsersViewController.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 15/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue

class UsersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var users: [TGUser] = []
    
    var meta: AnyObject?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(users)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
        // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UsersTableViewCell
        
        // Configure the cell...
        meta = users[indexPath.row].metadata as AnyObject
        if meta != nil {
            cell.userAboutLabel.text = String(meta!.valueForKey("about")!)
        }
        cell.userNameLabel.text = users[indexPath.row].username
        

        
        // Image
        var userImage = TGImage()
        userImage = users[indexPath.row].images.valueForKey("avatar") as! TGImage
        cell.userImageView.image = UIImage(named: userImage.url)
        
        return cell
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
