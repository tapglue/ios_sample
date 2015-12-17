//
//  HomeVC.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 14/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue

class HomeVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var homeTableView: UITableView!
    
    // Tapglue events array
//    var events: [TGEvent] = []
    var posts: [TGPost] = []
    
    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var userImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "loadFriendsActivityFeed", forControlEvents: UIControlEvents.ValueChanged)
        self.homeTableView.addSubview(refreshControl)
        self.homeTableView.sendSubviewToBack(refreshControl)
        
        var userImage = TGImage()
        userImage = TGUser.currentUser().images.valueForKey("avatar") as! TGImage
        self.userImageView.image = UIImage(named: userImage.url)
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
        
        Tapglue.retrievePostsFeedForCurrentUserWithCompletionBlock { (feed: [AnyObject]!, error: NSError!) -> Void in
            
            if error != nil {
                print("Error happened\n")
                print(error)
            }
            else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.posts = feed as! [TGPost]
                    self.homeTableView.reloadData()
                })
                self.refreshControl.endRefreshing()
            }
        }
        
//        Tapglue.retrieveNewsFeedForCurrentUserWithCompletionBlock { (posts : [AnyObject]!, feed : [AnyObject]!, error : NSError!) -> Void in
//            if error != nil {
//                print("Error happened\n")
//                print(error)
//            }
//            else {
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    self.events = feed as! [TGEvent]
//                    self.homeTableView.reloadData()
//                })
//                self.refreshControl.endRefreshing()
//            }
//        }
    }
    
    /*
    * TableView Methods
    */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! HomeTableViewCell
        
        
        let post = self.posts[indexPath.row]
        print(post)
        cell.configureCellWithPost(post)
        
        return cell
    }
    
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Show loginVC if no user
        textField.resignFirstResponder()
        self.performSegueWithIdentifier("postSegue", sender: nil)
        print("beginEditing")
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
