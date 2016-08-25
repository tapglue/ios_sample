//
//  PostViewWithStatus.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 25/08/16.
//  Copyright © 2016 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue
import Kingfisher
import AWSS3

// the name of the protocol you can put any
protocol PostStatusViewDataUpdater {
    func updatePostsWithStatusTableViewData()
    func showPostsWithStatusShareOptions(post: Post)
}

class PostViewWithStatus: UIView {
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    var delegate: PostStatusViewDataUpdater?
    
    var cellPost: Post!
    
    // Our custom view from the XIB file
    var cardView: UIView!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var visibilityImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    
    @IBOutlet weak var tagsView: UIView!
    
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
                    self.delegate?.updatePostsWithStatusTableViewData()
                    
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
                    self.delegate?.updatePostsWithStatusTableViewData()
                    
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
        delegate?.showPostsWithStatusShareOptions(cellPost)
    }
    
    // Configure Cell with Post data
    func configureViewWithPost(post: Post!){
        print(post)
        
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
        let postAttachments = post.attachments!
        self.postTextLabel.text = postAttachments[0].contents!["en"]
        
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
            button.frame = CGRectMake(x, 4, 60, 24)
            button.layer.cornerRadius = 12
            button.layer.masksToBounds = true
            button.backgroundColor = UIColor(white:0.92, alpha:1.0)
            button.tintColor = .darkGrayColor()
            button.titleLabel?.font = UIFont(name:"HelveticaNeue-Light", size: 13.0)
            button.setTitle(tag, forState: UIControlState.Normal)
            button.addTarget(self, action: #selector(PostViewWithStatus.action(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
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
    
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    func xibSetup() {
        cardView = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        cardView.frame = bounds
        
        // Make the view stretch with containing view
        cardView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(cardView)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "PostViewWithStatus", bundle: bundle)
        
        // Assumes UIView is top level and only object in CustomView.xib file
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
    }
    
}