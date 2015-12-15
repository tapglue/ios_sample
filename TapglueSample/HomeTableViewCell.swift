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
        
    }
    @IBAction func commentButtonPressed(sender: UIButton) {
        
    }
    @IBAction func shareButtonPressed(sender: UIButton) {
        
    }

    
    
    // Configure Cell with TGEvent data
    func configureCellWithPost(post: TGPost!){
        
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
        
//        var eventText = String()

//        if event.type == "" {
//
//            self.eventImageView.image = UIImage(named: "Friendship")
//            if event.target.objectId == TGUser.currentUser().objectId {
//                eventText = "is now your friend"
//            } else {
//                if event.target.user != nil {
//                    eventText = "just friended " + event.target.user.username
//                } else {
//                    eventText = "just friended another user"
//                }
//
//            }
//
//        } else {
//            eventText = event.type
//        }
//        self.eventNameLabel.text = eventText
//
//        var userImage = TGImage()
//        userImage = event.user.images.valueForKey("avatar") as! TGImage;
//
//        self.userImageView.image = UIImage(named: userImage.url)
//
//        
//        

//
//
//        let date = event.createdAt
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "hh:mm"
//        self.eventCreatedLabel.text = dateFormatter.stringFromDate(date)
    }


    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
