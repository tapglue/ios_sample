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
    
    var cellPost = TGPost()

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
        cellPost.likeWithCompletionBlock { (success: Bool, error: NSError!) -> Void in
            if error != nil {
                print("Error happened\n")
                print(error)
            }
            else {
                print("Success happened\n")
                print(success)
            }
        }
    }
    @IBAction func commentButtonPressed(sender: UIButton) {
        
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
        self.postTextLabel.text = postAttachment[0].content
        
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

    }


    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
