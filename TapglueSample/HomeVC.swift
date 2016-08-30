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
    
    var posts: [Post] = []
    
    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var userImageView: UIImageView!
    
    let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Refreshcontrol
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(HomeVC.loadFriendsActivityFeed), forControlEvents: UIControlEvents.ValueChanged)
        self.homeTableView.addSubview(refreshControl)
        self.homeTableView.sendSubviewToBack(refreshControl)
        
        self.refreshControl?.beginRefreshing()
        
        homeTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        if let profileImages = appDel.rxTapglue.currentUser?.images {
            self.userImageView.kf_setImageWithURL(NSURL(string: profileImages["profile"]!.url!)!)
        }
        
        self.loadFriendsActivityFeed()
    }
    
    func refresh(sender:AnyObject){
        self.refreshControl?.beginRefreshing()
        self.loadFriendsActivityFeed()
    }
    
    func loadFriendsActivityFeed() {
        // Load All Posts from your connections
        appDel.rxTapglue.retrievePostFeed().subscribe { (event) in
            switch event {
            case .Next(let posts):
                self.posts = posts
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                self.homeTableView.reloadData()
                self.refreshControl.endRefreshing()
            }
            }.addDisposableTo(self.appDel.disposeBag)
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
        
        
        // Show the post with customPostStatusView or customPostImageView
        if self.posts[indexPath.row].attachments!.count <= 1 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("PostWithStatusCell", forIndexPath: indexPath) as! PostWithStatusTableViewCell
            
            self.homeTableView.estimatedRowHeight = cell.frame.height
            
            cell.configureViewWithPost(self.posts[indexPath.row])
            // Listen custom delegate
            cell.delegate = self
            
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("PostWithImageCell", forIndexPath: indexPath) as! PostWithImageTableViewCell
            
            self.homeTableView.estimatedRowHeight = cell.frame.height
            
            cell.configureViewWithPost(self.posts[indexPath.row])
            // Listen custom delegate
            cell.delegate = self
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "PostDetail", bundle: nil)
        let pdVC =
            storyboard.instantiateViewControllerWithIdentifier("PostDetailViewController")
                as! PostDetailVC
        
        pdVC.post = posts[indexPath.row]
        pdVC.usr = posts[indexPath.row].user
        
        self.navigationController?.pushViewController(pdVC, animated: true)
    }
    
    // Remove dynamically created buttons
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let postImageCell = tableView.dequeueReusableCellWithIdentifier("PostWithImageCell", forIndexPath: indexPath) as! PostWithImageTableViewCell
        for view in postImageCell.tagsView.subviews {
            view.removeFromSuperview()
        }
        
        let postStatusCell = tableView.dequeueReusableCellWithIdentifier("PostWithStatusCell", forIndexPath: indexPath) as! PostWithStatusTableViewCell
        for view in postStatusCell.tagsView.subviews {
            view.removeFromSuperview()
        }
    }
}


extension HomeVC: UITextFieldDelegate {
    // Mark: - TextField
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.resignFirstResponder()
        
        // Go to PostVC
        self.performSegueWithIdentifier("postSegue", sender: nil)
    }
}


extension HomeVC: PostStatusViewDataUpdater {
    // Mark: - Custom delegate to update data, if cell recieves like button or share button pressed
    func updatePostsWithStatusTableViewData() {
        // Load All Posts from your connections
        appDel.rxTapglue.retrievePostFeed().subscribe { (event) in
            switch event {
            case .Next(let posts):
                self.posts = posts
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                self.homeTableView.reloadData()
                self.refreshControl.endRefreshing()
            }
            }.addDisposableTo(self.appDel.disposeBag)
    }
    
    func showPostsWithStatusShareOptions(post: Post) {
        let postAttachment = post.attachments
        let postText = postAttachment![0].contents!["en"]
        let postActivityItem = "@" + (post.user?.username)! + " posted: \(postText!)! Check it out on TapglueSample."
        
        let activityViewController: UIActivityViewController = UIActivityViewController(
            activityItems: [postActivityItem], applicationActivities: nil)
        
        activityViewController.excludedActivityTypes = [
            UIActivityTypePostToWeibo,
            UIActivityTypePrint,
            UIActivityTypeAssignToContact,
            UIActivityTypeSaveToCameraRoll,
            UIActivityTypeAddToReadingList,
            UIActivityTypePostToFlickr,
            UIActivityTypePostToVimeo,
            UIActivityTypePostToTencentWeibo,
            UIActivityTypeMail
        ]
        
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
}

extension HomeVC: PostImageViewDataUpdater {
    // Mark: - Custom delegate to update data, if cell recieves like button or share button pressed
    func updatePostsWithImageTableViewData() {
        // Load All Posts from your connections
        appDel.rxTapglue.retrievePostFeed().subscribe { (event) in
            switch event {
            case .Next(let posts):
                self.posts = posts
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                self.homeTableView.reloadData()
                self.refreshControl.endRefreshing()
            }
            }.addDisposableTo(self.appDel.disposeBag)
    }
    
    func showPostsWithImageShareOptions(post: Post) {
        let postAttachment = post.attachments
        let postText = postAttachment![0].contents!["en"]
        let postActivityItem = "@" + (post.user?.username)! + " posted: \(postText!)! Check it out on TapglueSample."
        
        let activityViewController: UIActivityViewController = UIActivityViewController(
            activityItems: [postActivityItem], applicationActivities: nil)
        
        activityViewController.excludedActivityTypes = [
            UIActivityTypePostToWeibo,
            UIActivityTypePrint,
            UIActivityTypeAssignToContact,
            UIActivityTypeSaveToCameraRoll,
            UIActivityTypeAddToReadingList,
            UIActivityTypePostToFlickr,
            UIActivityTypePostToVimeo,
            UIActivityTypePostToTencentWeibo,
            UIActivityTypeMail
        ]
        
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
}

