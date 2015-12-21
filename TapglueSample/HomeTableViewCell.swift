//
//  HomeTableViewCell.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 15/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue

class HomeTableViewCell: UITableViewCell {
    
    var cellPost: TGPost!

    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var visibilityImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postTextLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    @IBAction func likeButtonPressed(sender: UIButton) {
        
        if likeButton.selected == true {
            Tapglue.deleteLike(cellPost) { (success: Bool, error: NSError!) -> Void in
                if error != nil {
                    print("Error happened\n")
                    print(error)
                }
                else {
                    print("Success happened\n")
                    print(success)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.likeButton.selected = false
                    })
                }
            }
        } else {
            cellPost.likeWithCompletionBlock { (success: Bool, error: NSError!) -> Void in
                if error != nil {
                    print("Error happened\n")
                    print(error)
                }
                else {
                    print("Success happened\n")
                    print(success)
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
        
    }
    
    
    // Configure Cell with TGPost data
    func configureCellWithPost(post: TGPost!){
        
        cellPost = post
        
        // UserText
        self.userNameLabel.text = post.user.username
        
        // PostText
        let postAttachment = post.attachments
        self.postTextLabel.text = "\" " + postAttachment[0].content + " \""
        
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
        
        let date = post.createdAt
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        self.dateLabel.text = dateFormatter.stringFromDate(date)
        
        if cellPost.isLiked {
            likeButton.selected = true
        }
    }


    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
