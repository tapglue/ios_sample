//
//  PostDetailVC.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 21/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue

class PostDetailVC: UIViewController, UITableViewDelegate {
    
    var post: TGPost!
    var postComments: [TGPostComment] = []
    
    var commentButtonPressedSwitch: Bool = false
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var userNameButton: UIButton!
    
    @IBOutlet weak var commentsTableView: UITableView!
    
    @IBOutlet weak var commentTextField: UITextField!
    
    @IBOutlet weak var commentContainerBottonConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var visibilityImageView: UIImageView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    @IBAction func userNameButtonPressed(sender: UIButton) {
        let userProfileViewController = self.storyboard?.instantiateViewControllerWithIdentifier("UserProfileViewController") as! UserProfileVC
        
        userProfileViewController.userProfile = post.user
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.navigationController?.pushViewController(userProfileViewController, animated: true)
        })
    }
    
    @IBAction func likeButtonPressed(sender: UIButton) {
            if likeButton.selected == true {
                Tapglue.deleteLike(post) { (success: Bool, error: NSError!) -> Void in
                    if error != nil {
                        print("\nError happened:")
                        print(error)
                    }
                    else {
                        print("\nSuccessly deleted like from post:")
                        print(success)
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.likeButton.selected = false
                        })
                    }
                }
            } else {
                post.likeWithCompletionBlock { (success: Bool, error: NSError!) -> Void in
                    if error != nil {
                        print("\nError happened:")
                        print(error)
                    }
                    else {
                        print("\nSuccessly liked a post:")
                        print(success)
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.likeButton.selected = true
                            
                        })
                    }
            }
        }
    }
    
    
    // MARK: - Keyboard Notification
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
        })
    }
    
    func keyboardWillHideNotification(notification:NSNotification){
        self.commentContainerBottonConstraint.constant = 0
        self.view.layoutIfNeeded()
    }
    
    // Retrieve all comments and reverse them
    func retrieveAllCommentsForPost(){
        Tapglue.retrieveCommentsForPost(post) { (comments: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                print("Error happened\n")
                print(error)
            }
            else {
                self.postComments = (comments as! [TGPostComment]).reverse()
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.commentsTableView.reloadData()
                })
            }
        }
    }
    
    // Show postDetails
    func fillPostDetailInformation(){
        userNameButton.contentHorizontalAlignment = .Left
        userNameButton.setTitle(post.user.username, forState: .Normal)
        
        if post.likesCount != 0 {
            if post.likesCount == 1{
                self.likesCountLabel.text = String(post.likesCount) + " Like"
            }
            self.likesCountLabel.text = String(post.likesCount) + " Likes"
        }
        
        if post.commentsCount != 0 {
            if post.commentsCount == 1 {
                self.commentsCountLabel.text = String(post.commentsCount) + " Comment"
            }
            self.commentsCountLabel.text = String(post.commentsCount) + " Comments"
        }
        
        // PostText
        let postAttachment = post.attachments
        self.postTextLabel.text = "\" " + postAttachment[0].content + " \""
        
        // Date to string
        self.dateLabel.text = post.createdAt.toStringFormatHoursMinutes()
        
        // User Avatar Image from sample asset
        var userImage = TGImage()
        userImage = post.user.images.valueForKey("profilePic") as! TGImage
        self.userImageView.downloadedFrom(link: userImage.url, contentMode: .ScaleAspectFill)
        
        // Check visibility
        switch post.visibility {
        case TGVisibility.Private:
            self.visibilityImageView.image = UIImage(named: "privateFilled")
            
        case TGVisibility.Connection:
            self.visibilityImageView.image = UIImage(named: "connectionFilled")
            
        case TGVisibility.Public:
            self.visibilityImageView.image = UIImage(named: "publicFilled")
        }
        
        // Check if post isLiked already
        if post.isLiked {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.likeButton.selected = true
            })
        } else {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.likeButton.selected = false
            })
        }
    }
}

extension PostDetailVC: UITableViewDataSource {
    // Mark: - TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postComments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PostDetailCommentsTableViewCell
        
        cell.userImageView.image = nil
        
        cell.configureCellWithPostComment(postComments[indexPath.row])
        
        return cell
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let edit = UITableViewRowAction(style: .Normal, title: "Edit") { action, index in
            print("favorite button tapped")
        }
        edit.backgroundColor = UIColor.lightGrayColor()
        
        let delete = UITableViewRowAction(style: .Destructive, title: "Delete") { action, index in
            print("share button tapped")
            Tapglue.deleteComment(self.postComments[indexPath.row], withCompletionBlock: { (success: Bool, error: NSError!) -> Void in
                if error != nil {
                    print("Error happened\n")
                    print(error)
                }
                else {
                    print(success)
                    
                    self.retrieveAllCommentsForPost()
                }
            })
        }
        delete.backgroundColor = UIColor.redColor()
        
        return [delete, edit]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let userProfileViewController = self.storyboard?.instantiateViewControllerWithIdentifier("UserProfileViewController") as! UserProfileVC
        
        userProfileViewController.userProfile = postComments[indexPath.row].user
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.navigationController?.pushViewController(userProfileViewController, animated: true)
        })
    }
}

extension PostDetailVC: UITextFieldDelegate {
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
}