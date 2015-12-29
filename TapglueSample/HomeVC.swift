//
//  HomeVC.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 14/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue

class HomeVC: UIViewController, UITableViewDelegate{

    @IBOutlet weak var homeTableView: UITableView!
    
    // TGPost array
    var posts: [TGPost] = []
    
    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var userImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "loadFriendsActivityFeed", forControlEvents: UIControlEvents.ValueChanged)
        self.homeTableView.addSubview(refreshControl)
        self.homeTableView.sendSubviewToBack(refreshControl)
        
        // UserImage
        var userImage = TGImage()
        userImage = TGUser.currentUser().images.valueForKey("profilePic") as! TGImage
        self.userImageView.downloadedFrom(link: userImage.url, contentMode: .ScaleAspectFill)
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
                print("\nError happened")
                print(error)
            }
            else {
                self.posts = feed as! [TGPost]

                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.homeTableView.reloadData()
                })
                
                self.refreshControl.endRefreshing()
            }
        }
    }
    

}


extension HomeVC: UITableViewDataSource {
    // Mark: - TableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! HomeTableViewCell
        
        
        print("Current cell number is: \([indexPath.row])")
        cell.userImageView.image = nil
        cell.configureCellWithPost(self.posts[indexPath.row])
        cell.delegate = self
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let pdVC =
        self.storyboard!.instantiateViewControllerWithIdentifier("PostDetailViewController")
            as! PostDetailVC
        
        // pass data
        pdVC.post = posts[indexPath.row]
        
        // tell the new controller to present itself
        self.navigationController!.pushViewController(pdVC, animated: true)
    }
}


extension HomeVC: UITextFieldDelegate {
    // Mark: - TextField
    func textFieldDidBeginEditing(textField: UITextField) {
        // Show PostVC
        textField.resignFirstResponder()
        self.performSegueWithIdentifier("postSegue", sender: nil)
    }
}


extension HomeVC: CustomCellDataUpdater {
    // Mark: - Custom delegate
    func updateTableViewData() {
        Tapglue.retrievePostsFeedForCurrentUserWithCompletionBlock { (feed: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                print("\nError happened")
                print(error)
            }
            else {
                self.posts = feed as! [TGPost]
            }
        }
    }
}
