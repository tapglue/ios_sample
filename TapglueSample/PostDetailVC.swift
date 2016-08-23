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
    
    let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    var usr: User?
    var post: Post!
    var postComments: [Comment] = []
    
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
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    
    var beginEditComment = false
    var editComment: Comment!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if post != nil {
            print("PostDetail: \(post)")
            fillPostDetailInformation()
        }

        // Show keyboard and start commenting
        if commentButtonPressedSwitch {
            commentTextField.becomeFirstResponder()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        retrieveAllCommentsForPost()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PostDetailVC.keyboardWillShowNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PostDetailVC.keyboardWillHideNotification(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    @IBAction func userNameButtonPressed(sender: UIButton) {
        let storyboard = UIStoryboard(name: "UserProfile", bundle: nil)
        let userProfileViewController = storyboard.instantiateViewControllerWithIdentifier("UserProfileViewController") as! UserProfileVC
        
        userProfileViewController.userProfile = usr
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.navigationController?.pushViewController(userProfileViewController, animated: true)
        })
    }
    
    @IBAction func likeButtonPressed(sender: UIButton) {
            if likeButton.selected == true {
                // Delete like for Post
                appDel.rxTapglue.deleteLike(forPostId: post.id!).subscribe({ (event) in
                    switch event {
                    case .Next(let element):
                        print(element)
                    case .Error(let error):
                        self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                    case .Completed:
                        print("Do tha action")
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.likeButton.selected = false
                            self.updateLikeCountLabel()
                        })
                    }
                }).addDisposableTo(self.appDel.disposeBag)

            } else {
                // Create like for Post
                appDel.rxTapglue.createLike(forPostId: post.id!).subscribe({ (event) in
                    switch event {
                    case .Next(let element):
                        print(element)
                    case .Error(let error):
                        self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                    case .Completed:
                        print("Do tha action")
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.likeButton.selected = true
                            self.updateLikeCountLabel()
                        })
                    }
                }).addDisposableTo(self.appDel.disposeBag)
            }
    }
    
    @IBAction func shareButtonPressed(sender: UIButton) {
        showShareOptions()
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
        // Retrieve comments for Post
        appDel.rxTapglue.retrieveComments(post.id!).subscribe { (event) in
                switch event {
                case .Next(let comments):
                    self.postComments = (comments).reverse()
                case .Error(let error):
                    self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                case .Completed:
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.commentsTableView.reloadData()
                    })
                }
        }.addDisposableTo(self.appDel.disposeBag)
    }
    
    // Show PostDetial information
    func fillPostDetailInformation(){
        userNameButton.contentHorizontalAlignment = .Left
        if let postUser = usr {
            userNameButton.setTitle(postUser.username, forState: .Normal)
            
            if let profileImages = postUser.images {
                self.userImageView.kf_setImageWithURL(NSURL(string: profileImages["profile"]!.url!)!)
            }
        }
        
        // Post like count
        let likeCountForPost = post.likeCount!
        
        if likeCountForPost != 0 {
            if likeCountForPost == 1{
                self.likesCountLabel.text = String(likeCountForPost) + " Like"
            } else {
                self.likesCountLabel.text = String(likeCountForPost) + " Likes"
            }
        } else {
            self.likesCountLabel.text = ""
        }
        
        // PostText
        let postAttachment = post.attachments
        self.postTextLabel.text = postAttachment![0].contents!["en"]
        // OldSDK : needs to show elpased time
        self.dateLabel.text = post.createdAt!.toNSDateTime().toStringFormatDayMonthYear()
        
        // TagsText
        if let tags = post.tags {
            var tagLabelText = ""
            
            switch tags.count {
            case 1:
                for tag in tags {
                    self.tagsLabel.text = "Tag: " + tag
                }
            case 2...5:
                for tag in tags {
                    tagLabelText = tagLabelText + "\(tag) "
                }
                self.tagsLabel.text = "Tags: " + tagLabelText
            default:
                print("switch default tags")
            }
            
        } else {
            self.tagsLabel.text = ""
        }
        
        // Check visibility
        switch post.visibility! {
        case Visibility.Private:
            self.visibilityImageView.image = UIImage(named: "privateFilled")
            
        case Visibility.Connections:
            self.visibilityImageView.image = UIImage(named: "connectionFilled")
            
        case Visibility.Public:
            self.visibilityImageView.image = UIImage(named: "publicFilled")
        }
        
        // Check if post isLiked already
        if post.isLiked! {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.likeButton.selected = true
            })
        } else {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.likeButton.selected = false
            })
        }
    }
    
    func showShareOptions() {
        let postAttachment = post.attachments
        let postText = postAttachment![0].contents!["en"]
        if let postUserUsername = post.user?.username {
            let postActivityItem = "@" + postUserUsername + " posted: \(postText!)! Check it out on TapglueSample."
            
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
    
    func updateLikeCountLabel() {
        appDel.rxTapglue.retrievePost(post.id!).subscribe { (event) in
            switch event {
            case .Next(let post):
                let likeCount = post.likeCount!
                
                if likeCount != 0 {
                    if likeCount == 1{
                        self.likesCountLabel.text = String(likeCount) + " Like"
                    } else {
                        self.likesCountLabel.text = String(likeCount) + " Likes"
                    }
                }
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                break
                
            }
            }.addDisposableTo(self.appDel.disposeBag)
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
        
        cell.configureCellWithPostComment(postComments[indexPath.row])
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Check if comment is own comment to edit it
        if self.postComments[indexPath.row].userId == appDel.rxTapglue.currentUser?.id {
            return true
        } else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
            let edit = UITableViewRowAction(style: .Normal, title: "Edit") { action, index in
                print("favorite button tapped")
                
                self.beginEditComment = true
                
                self.commentTextField.becomeFirstResponder()
                
                let commentText: String = self.postComments[indexPath.row].contents!["en"]! 
                self.commentTextField.text = commentText
                
                self.editComment = self.postComments[indexPath.row]
            }
            edit.backgroundColor = UIColor.lightGrayColor()
            
            let delete = UITableViewRowAction(style: .Destructive, title: "Delete") { action, index in
                // Delete comment for Post
                self.appDel.rxTapglue.deleteComment(forPostId: self.post.id!, commentId: self.postComments[indexPath.row].id!).subscribeCompleted({ 
                    self.retrieveAllCommentsForPost()
                }).addDisposableTo(self.appDel.disposeBag)
            }
            delete.backgroundColor = UIColor.redColor()
            return [delete, edit]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "UserProfile", bundle: nil)
        let userProfileViewController = storyboard.instantiateViewControllerWithIdentifier("UserProfileViewController") as! UserProfileVC
        
        userProfileViewController.userProfile = postComments[indexPath.row].user
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.navigationController?.pushViewController(userProfileViewController, animated: true)
        })
    }
}

extension PostDetailVC: UITextFieldDelegate {
    // Mark: - TextField
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if beginEditComment {
            let contents = ["en": textField.text!]
            self.editComment.contents = contents
            
            // Update comment for Post
            appDel.rxTapglue.updateComment(post.id!, commentId: editComment.id!, comment: editComment).subscribe({ (event) in
                switch event {
                case .Next( _):
                    self.retrieveAllCommentsForPost()
                case .Error(let error):
                    self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                case .Completed:
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.commentsTableView.reloadData()
                        self.commentTextField.text = nil
                        self.commentTextField.resignFirstResponder()
                        self.beginEditComment = false
                    })
                }
            }).addDisposableTo(self.appDel.disposeBag)

        } else {
            
            let comment = Comment(contents: ["en":textField.text!], postId: post.id!)
            
            // Create comment for Post
            appDel.rxTapglue.createComment(comment).subscribe({ (event) in
                switch event {
                case .Next( _):
                    self.retrieveAllCommentsForPost()
                case .Error(let error):
                    self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                case .Completed:
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.commentsTableView.reloadData()
                        self.commentTextField.text = nil
                        self.commentTextField.resignFirstResponder()
                        self.beginEditComment = false
                    })
                }
            }).addDisposableTo(self.appDel.disposeBag)
        }
        return true
    }
}
