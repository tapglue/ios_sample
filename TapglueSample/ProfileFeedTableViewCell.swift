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
    
    @IBOutlet weak var infoLabel: UILabel!
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
        
        let date = post.createdAt
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "d MMMM y"
        self.infoLabel.text = dateFormatter.stringFromDate(date)
        
        // PostText
        let postAttachment = post.attachments
        self.typeLabel.text = postAttachment[0].content
        
    }

    // Configure Cell with TGEvent data
    func configureCellWithEvent(event: TGEvent!){
        
        switch event.type {
        case "like_event":
            self.infoLabel.text = "Liked"
        case "bookmark_event":
            self.infoLabel.text = "Bookmarked"
        default: print("More event types then expected")
        }
        
//        self.userName.text = event.type
        
        if event.object != nil {
            self.typeLabel.text = event.object.objectId
        }
    }

}
