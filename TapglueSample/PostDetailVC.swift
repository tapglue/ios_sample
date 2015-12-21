//
//  PostDetailVC.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 21/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue

class PostDetailVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    var post: TGPost!
    var postComments: [TGPostComment] = []
    
    var commentButtonPressedSwitch: Bool = false

    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var commentContainerBottonConstraint: NSLayoutConstraint!
    
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

        // Start commenting, when you pressed comment button in HomeTableViewCell
        if commentButtonPressedSwitch {
            commentTextField.becomeFirstResponder()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        retrieveAllCommentsForPost()
        print(postComments.count)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    // MARK: - Keyboard Notifications
    func keyboardWillShowNotification(notification:NSNotification){
        let userInfo = notification.userInfo!
        
        let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let animationOptions = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16))
        let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        UIView.animateWithDuration(animationDuration,
            delay: 0,
            options: animationOptions,
            animations: {
                self.commentContainerBottonConstraint.constant = keyboardFrame.size.height
                self.view.layoutIfNeeded()
            },
            completion: { completed in
//                self.commentsTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.postComments.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.None, animated: true)
        })
    }
    
    func keyboardWillHideNotification(notification:NSNotification){
        self.commentContainerBottonConstraint.constant = 0
        self.view.layoutIfNeeded()
    }


    
    // Mark: - TableView
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
    
    // Mark: - TextField
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print(textField.text!)
        Tapglue.createCommentWithContent(textField.text!, forPost: post) { (success: Bool, error: NSError!) -> Void in
            if error != nil {
                print("Error happened\n")
                print(error)
            }
            else {
                print(success)
                self.retrieveAllCommentsForPost()
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.commentsTableView.reloadData()
                    self.commentTextField.text = nil
                    self.commentTextField.resignFirstResponder()
                })
            }
        }
        
        
        return true
    }
    
    // Retrieve all comments and reverse them
    func retrieveAllCommentsForPost(){
        Tapglue.retrieveCommentsForPost(post) { (comments: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                print("Error happened\n")
                print(error)
            }
            else {
                print(comments)
                
                self.postComments = (comments as! [TGPostComment]).reverse()
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.commentsTableView.reloadData()
                })
            }
        }
    }
    
    // Show postDetails
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
