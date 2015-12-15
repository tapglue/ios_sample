//
//  ProfileFeedTableViewCell.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 15/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue

class ProfileFeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Configure Cell with TGEvent data
    func configureCellWithPost(post: TGPost!){
        
        self.userName.text = post.user.username
        
        // PostText
        let postAttachment = post.attachments
        self.typeLabel.text = postAttachment[0].name
        
//        // UserText
//        self.userNameLabel.text = post.user.username
//        
//        // PostText
//        let postAttachment = post.attachments
//        self.postTextLabel.text = postAttachment[0].content
//        
//        var userImage = TGImage()
//        userImage = post.user.images.valueForKey("avatar") as! TGImage
//        self.userImageView.image = UIImage(named: userImage.url)
//        
//        // Check visibility
//        switch post.visibility {
//        case TGVisibility.Private:
//            self.visibilityImageView.image = UIImage(named: "privateFilled")
//            
//        case TGVisibility.Connection:
//            self.visibilityImageView.image = UIImage(named: "connectionFilled")
//            
//        case TGVisibility.Public:
//            self.visibilityImageView.image = UIImage(named: "publicFilled")
//        }
//        
//        let date = post.createdAt
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "hh:mm"
//        self.dateLabel.text = dateFormatter.stringFromDate(date)
    }

    // Configure Cell with TGEvent data
    func configureCellWithEvent(event: TGEvent!){
        
        self.userName.text = event.user.username

        self.typeLabel.text = event.type
        
//        // UserText
//        self.userNameLabel.text = post.user.username
//        
//        // PostText
//        let postAttachment = post.attachments
//        self.postTextLabel.text = postAttachment[0].content
//        
//        var userImage = TGImage()
//        userImage = post.user.images.valueForKey("avatar") as! TGImage
//        self.userImageView.image = UIImage(named: userImage.url)
//        
//        // Check visibility
//        switch post.visibility {
//        case TGVisibility.Private:
//            self.visibilityImageView.image = UIImage(named: "privateFilled")
//            
//        case TGVisibility.Connection:
//            self.visibilityImageView.image = UIImage(named: "connectionFilled")
//            
//        case TGVisibility.Public:
//            self.visibilityImageView.image = UIImage(named: "publicFilled")
//        }
//        
//        let date = post.createdAt
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "hh:mm"
//        self.dateLabel.text = dateFormatter.stringFromDate(date)
        
    }

}
