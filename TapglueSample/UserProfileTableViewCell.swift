//
//  UserProfileTableViewCell.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 18/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue

class UserProfileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // Configure Cell with TGPost
    func configureCellWithPost(post: TGPost!){
        // Date to string
        let date = post.createdAt
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        self.dateLabel.text = dateFormatter.stringFromDate(date)
        
        // PostText
        let postAttachment = post.attachments
        self.infoLabel.text = postAttachment[0].content
        
    }
    
    // Configure Cell with TGEvent
    func configureCellWithEvent(event: TGEvent!){
        // Date to string
        let date = event.createdAt
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        self.dateLabel.text = dateFormatter.stringFromDate(date)
        
        switch event.type {
            case "like_event":
                self.typeLabel.text = "Liked"
            case "bookmark_event":
                self.typeLabel.text = "Bookmarked"
            case "tg_friend":
                self.typeLabel.text = "Added Friend"
            case "tg_like":
                self.typeLabel.text = "Liked Post"
            default: print("More event types then expected")
        }
        
        self.infoLabel.text = event.tgObjectId
        
        if event.object != nil {
            self.infoLabel.text = event.object.objectId
        }
    }

}
