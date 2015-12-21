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
    
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

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
        
        let date = post.createdAt
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        self.dateLabel.text = dateFormatter.stringFromDate(date)
        
        // PostText
        let postAttachment = post.attachments
        self.infoLabel.text = postAttachment[0].content
        
    }
    
    // Configure Cell with TGEvent data
    func configureCellWithEvent(event: TGEvent!){
        
        let date = event.createdAt
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        self.dateLabel.text = dateFormatter.stringFromDate(date)
        
        switch event.type {
        case "like_event":
            self.infoLabel.text = "Liked"
        case "bookmark_event":
            self.infoLabel.text = "Bookmarked"
        case "tg_friend":
            self.infoLabel.text = "Added Friend"
        default: print("More event types then expected")
        }
    }

}
