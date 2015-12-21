//
//  PostDetailVC.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 21/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue

class PostDetailVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var post: TGPost!
    var postComments: [TGPostComment] = []

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var visibilityImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if post != nil {
           print("PostDetail: \(post)")
            fillPostDetailInformation()
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        retrieveAllCommentsForPost()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fillPostDetailInformation(){
        userNameLabel.text = post.user.username
        
        // PostText
        let postAttachment = post.attachments
        self.postTextLabel.text = "\" " + postAttachment[0].content + " \""

        let date = post.createdAt
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        self.dateLabel.text = dateFormatter.stringFromDate(date)
        
        // User Avatar Image from sample asset
        var userImage = TGImage()
        userImage = post.user.images.valueForKey("avatar") as! TGImage
        self.userImageView.image = UIImage(named: userImage.url)
        
        // Check visibility
        switch post.visibility {
        case TGVisibility.Private:
            self.visibilityImageView.image = UIImage(named: "privateFilled")
            
        case TGVisibility.Connection:
            self.visibilityImageView.image = UIImage(named: "connectionFilled")
            
        case TGVisibility.Public:
            self.visibilityImageView.image = UIImage(named: "publicFilled")
        }
    }
    
    // Mark: - TablewView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postComments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PostDetailCommentsTableViewCell
        
        // Configure cell
        cell.configureCellWithPostComment(postComments[indexPath.row])

        
        return cell
    }
    
    
    func retrieveAllCommentsForPost(){
        Tapglue.retrieveCommentsForPost(post) { (comments: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                print("Error happened\n")
                print(error)
            }
            else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.postComments = comments as! [TGPostComment]
                })
            }
        }
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
