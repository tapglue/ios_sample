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
    
    @IBOutlet weak var tagsView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        

    }
    
    @IBAction func likeButtonPressed(sender: UIButton) {
        if likeButton.selected == true {
            // Delete like of post
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
            // Create like of post
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
        
        // Pass the relevant data to the new sub-ViewController
        pdVC.post = cellPost
        pdVC.usr = cellPost.user
        pdVC.commentButtonPressedSwitch = true
        
        rootViewController.pushViewController(pdVC, animated: true)
    }
    
    @IBAction func shareButtonPressed(sender: UIButton) {
        delegate?.showShareOptions(cellPost)
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
        
        
        // TagsBtn
        if let tags = post.tags {
            self.createTagBtns(tags.count, tags: tags)
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.likeButton.selected = false
        })

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
    
    func createTagBtns(tagsCount: Int, tags: [String]) {
        var x: CGFloat = 0
        for tag in tags {
            let button = UIButton(type: .System)
            button.frame = CGRectMake(x, 0, 60, self.tagsView.frame.height)
            button.layer.cornerRadius = tagsView.frame.height / 2
            button.layer.masksToBounds = true
            button.backgroundColor = .lightGrayColor()
            button.tintColor = .whiteColor()
            button.titleLabel?.font = UIFont(name:"HelveticaNeue-Light", size: 13.0)
            button.setTitle(tag, forState: UIControlState.Normal)
            button.addTarget(self, action: #selector(HomeTableViewCell.action(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            self.tagsView.addSubview(button)
            
            x += 68
        }
        
    }
    
    func action(sender:UIButton) {
       print("acion was pressed \(sender.titleLabel?.text!)")
        // TODO: filterPostTags
            let tag = sender.titleLabel?.text!
            let tags: [String] = [tag!]
            appDel.rxTapglue.filterPostsByTags(tags).subscribe { (event) in
                switch event {
                case .Next(let posts):
                    print("Next")
                    for post in posts {
                        print("filterdPosts: \(post.attachments![0].contents!["en"])")
                    }
                    let rootViewController = self.window!.rootViewController as! UINavigationController
                    let storyboard = UIStoryboard(name: "FilteredTags", bundle: nil)
                    let pdVC =
                        storyboard.instantiateViewControllerWithIdentifier("FilteredTagsViewController")
                            as! FilteredTagsVC
                    
                    // Pass the relevant data to the new sub-ViewController
                    pdVC.posts = posts
                    pdVC.tags = tags
                    
                    rootViewController.pushViewController(pdVC, animated: true)
                case .Error(let error):
                    self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                case .Completed:
                    print("Do the action")
                }
            }.addDisposableTo(self.appDel.disposeBag)
    }
}

