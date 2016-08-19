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
    func showShareOptions(post: Post)
}

class HomeTableViewCell: UITableViewCell {
    
    // Get the AppDelegate
    let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    var delegate: CustomCellDataUpdater?
    
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
    
    @IBAction func likeButtonPressed(sender: UIButton) {
        if likeButton.selected == true {
            //NewSDK
            appDel.rxTapglue.deleteLike(forPostId: cellPost.id!).subscribe({ (event) in
                switch event {
                case .Next(let element):
                    print(element)
                case .Error(let error):
                    self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                case .Completed:
                    print("Do tha action")
                    self.delegate?.updateTableViewData()

                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.likeButton.selected = false
                    })
                }
            }).addDisposableTo(self.appDel.disposeBag)
            
        } else {
            // NewSDK
            appDel.rxTapglue.createLike(forPostId: cellPost.id!).subscribe({ (event) in
                switch event {
                case .Next(let element):
                    print(element)
                case .Error(let error):
                    self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                case .Completed:
                    print("Do tha action")
                    self.delegate?.updateTableViewData()

                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.likeButton.selected = true
                    })
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
        
        // pass the relevant data to the new sub-ViewController
        pdVC.post = cellPost
        pdVC.commentButtonPressedSwitch = true
        
        // tell the new controller to present itself
        rootViewController.pushViewController(pdVC, animated: true)
    }
    
    @IBAction func shareButtonPressed(sender: UIButton) {
        // Will be implemented in the future
        print("Not implemented yet")
        delegate?.showShareOptions(cellPost)
    }
    
    // Configure Cell with TGPost data
    func configureCellWithPost(post: Post!){
        cellPost = post
        
        let cellPostLikeCount = cellPost.likeCount!
        
        switch cellPostLikeCount {
        case 0:
            self.likesCountLabel.text = ""
        case 1:
            self.likesCountLabel.text = String(cellPostLikeCount) + " Like"
        case 2...100000:
            self.likesCountLabel.text = String(cellPostLikeCount) + " Likes"
        default:
            print("switch default likesCount")
        }
        
        let cellPostCommentCount = cellPost.commentCount!
        
        switch cellPostCommentCount {
        case 0:
            self.commentsCountLabel.text = ""
        case 1:
            self.commentsCountLabel.text = String(cellPostCommentCount) + " Comment"
        case 2...100000:
            self.commentsCountLabel.text = String(cellPostCommentCount) + " Comments"
        default:
            print("switch default commentsCount")
        }
        
        // UserText
        self.userNameLabel.text = cellPost.user?.username
        
        // PostText
        let postAttachment = post.attachments
        self.postTextLabel.text = postAttachment![0].contents!["en"]
        
        
        // TagsText
        if let tags = post.tags {
            var tagLabelText = ""
            
            switch tags.count {
            case 1:
                for tag in tags {
                    self.tagLabel.text = "Tag: " + tag
                }
            case 2...5:
                for tag in tags {
                    tagLabelText = tagLabelText + "\(tag) "
                }
                self.tagLabel.text = "Tags: " + tagLabelText
            default:
                print("switch default tags")
            }
            
        } else {
            self.tagLabel.text = ""
        }

        
        // TODO: Check nil
        // UserImage
        let profileImage = post.user?.images!["profile"]
        self.userImageView.kf_setImageWithURL(NSURL(string: profileImage!.url!)!)

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

