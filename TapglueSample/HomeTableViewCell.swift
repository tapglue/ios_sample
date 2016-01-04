//
//  HomeTableViewCell.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 15/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue
import Kingfisher

// the name of the protocol you can put any
protocol CustomCellDataUpdater {
    func updateTableViewData()
}

class HomeTableViewCell: UITableViewCell {
    
    var delegate: CustomCellDataUpdater?
    
    var cellPost: TGPost!

    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var visibilityImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func likeButtonPressed(sender: UIButton) {
        if likeButton.selected == true {
            Tapglue.deleteLike(cellPost) { (success: Bool, error: NSError!) -> Void in
                if error != nil {
                    print("\nError deleteLike: \(error)")
                }
                else {
                    print("\nSuccessly deleted like from post: \(success)")
                    
                    self.delegate?.updateTableViewData()
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.likeButton.selected = false
                    })
                }
            }
        } else {
            cellPost.likeWithCompletionBlock { (success: Bool, error: NSError!) -> Void in
                if error != nil {
                    print("\nError like: \(error)")
                }
                else {
                    print("\nSuccessly liked a post: \(success)")
                    
                    self.delegate?.updateTableViewData()
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.likeButton.selected = true
                    })
                }
            }
        }
    }
    
    @IBAction func commentButtonPressed(sender: UIButton) {
        let rootViewController = self.window!.rootViewController as! UINavigationController
        let main: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let pdVC =
        main.instantiateViewControllerWithIdentifier("PostDetailViewController")
            as! PostDetailVC
        
        // pass the relevant data to the new sub-ViewController
        pdVC.post = cellPost
        pdVC.commentButtonPressedSwitch = true
        
        // tell the new controller to present itself
        rootViewController.pushViewController(pdVC, animated: true)
    }
    
    @IBAction func shareButtonPressed(sender: UIButton) {
        // Will be implemented in the future
    }
    
    // Configure Cell with TGPost data
    func configureCellWithPost(post: TGPost!){
        cellPost = post
        
        if cellPost.likesCount != 0 {
            if cellPost.likesCount == 1{
                self.likesCountLabel.text = String(cellPost.likesCount) + " Like"
            }
            self.likesCountLabel.text = String(cellPost.likesCount) + " Likes"
        }
        
        if cellPost.commentsCount != 0 {
            if cellPost.commentsCount == 1 {
                self.commentsCountLabel.text = String(cellPost.commentsCount) + " Comment"
            }
            self.commentsCountLabel.text = String(cellPost.commentsCount) + " Comments"
        }
        
        // UserText
        self.userNameLabel.text = post.user.username
        
        // PostText
        let postAttachment = post.attachments
        self.postTextLabel.text = "\" " + postAttachment[0].content + " \""
        
        // UserImage
        var userImage = TGImage()
        userImage = post.user.images.valueForKey("profilePic") as! TGImage
        self.userImageView.kf_setImageWithURL(NSURL(string: userImage.url)!)

        // Check visibility
        switch post.visibility {
            case TGVisibility.Private:
                self.visibilityImageView.image = UIImage(named: "privateFilled")
                
            case TGVisibility.Connection:
                self.visibilityImageView.image = UIImage(named: "connectionFilled")
                
            case TGVisibility.Public:
                self.visibilityImageView.image = UIImage(named: "publicFilled")
        }
        
        // Date text
        self.dateLabel.text = post.createdAt.timeFormatInElapsedTimeToString()
        
        // Check if post was liked before
        if cellPost.isLiked {
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
