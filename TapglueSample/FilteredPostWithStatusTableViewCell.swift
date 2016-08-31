//
//  FilteredPostWithStatusTableViewCell.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 31/08/16.
//  Copyright © 2016 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue
import Kingfisher

// the name of the protocol you can put any
protocol FilteredPostWithStatusCellDataUpdater {
    func updateFilteredPostWithStatusTableViewData()
    func showFilteredPostWithStatusShareOptions(post: Post)
}

class FilteredPostWithStatusTableViewCell: UITableViewCell {

    let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    var delegate: FilteredPostWithStatusCellDataUpdater?
    
    var cellPost: Post!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var visibilityImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func likeButtonPressed(sender: UIButton) {
        if likeButton.selected == true {
            // Delete like of post
            appDel.rxTapglue.deleteLike(forPostId: cellPost.id!).subscribe({ (event) in
                switch event {
                case .Next( _):
                    print("Next")
                case .Error(let error):
                    self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                case .Completed:
                    print("Completed")
                    self.delegate?.updateFilteredPostWithStatusTableViewData()
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.likeButton.selected = false
                    })
                }
            }).addDisposableTo(self.appDel.disposeBag)
            
        } else {
            // Create like of post
            appDel.rxTapglue.createLike(forPostId: cellPost.id!).subscribe({ (event) in
                switch event {
                case .Next( _):
                    print("Next")
                case .Error(let error):
                    self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                case .Completed:
                    print("Completed")
                    self.delegate?.updateFilteredPostWithStatusTableViewData()
                    
                    self.likeButton.selected = true
                }
            }).addDisposableTo(self.appDel.disposeBag)
        }
    }
    
    @IBAction func commentButtonPressed(sender: UIButton) {
        let rootViewController = self.window!.rootViewController as! UINavigationController
        let storyboard = UIStoryboard(name: "PostDetail", bundle: nil)
        let pdVC =
            storyboard.instantiateViewControllerWithIdentifier("PostDetailViewController")
                as! PostDetailVC
        
        // Pass the relevant data to the new sub-ViewController
        pdVC.post = cellPost
        pdVC.userID = cellPost.userId
        pdVC.commentButtonPressedSwitch = true
        
        rootViewController.pushViewController(pdVC, animated: true)
    }
    
    @IBAction func shareButtonPressed(sender: UIButton) {
        delegate?.showFilteredPostWithStatusShareOptions(cellPost)
    }
    
    // Configure Cell with Post data
    func configureCellWithPost(post: Post!){
        cellPost = post
        
        // PostLikeCount
        let cellPostLikeCount = cellPost.likeCount!
        
        if cellPostLikeCount != 0 {
            if cellPostLikeCount == 1{
                self.likesCountLabel.text = String(cellPostLikeCount) + " Like"
            } else {
                self.likesCountLabel.text = String(cellPostLikeCount) + " Likes"
            }
        } else {
            self.likesCountLabel.text = ""
        }
        
        // PostCommentCount
        let cellPostCommentCount = cellPost.commentCount!
        
        if cellPostCommentCount != 0 {
            if cellPostCommentCount == 1{
                self.commentsCountLabel.text = String(cellPostCommentCount) + " Comment"
            } else {
                self.commentsCountLabel.text = String(cellPostCommentCount) + " Comments"
            }
        } else {
            self.commentsCountLabel.text = ""
        }
        
        // UserText
        self.userNameLabel.text = cellPost.user?.username
        
        // PostText
        let postAttachment = post.attachments
        self.postTextLabel.text = postAttachment![0].contents!["en"]
        
        
        // TagsText
        if let tags = post.tags {
            if tags.count == 1 {
                tagLabel.text = "Tag: " + tags[0]
            } else {
                var allTags = ""
                for tag in tags {
                    allTags += " \(tag)"
                }
                tagLabel.text = "Tags: " + allTags
            }
        } else {
            tagLabel.text = ""
        }
        
        if let profileImages = post.user?.images {
            self.userImageView.kf_setImageWithURL(NSURL(string: profileImages["profile"]!.url!)!)
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
        
        // StringDate to elapsedTimeString
        self.dateLabel.text = cellPost.createdAt!.toNSDateTime().toTimeFormatInElapsedTimeToString()
        
        // Check if post was liked before
        if cellPost.isLiked! {
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