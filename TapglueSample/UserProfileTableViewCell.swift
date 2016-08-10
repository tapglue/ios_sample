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
    
    func configureCellWithPost(post: TGPost!){
        clearLabels()
        
        // Post attachment
        let postAttachment = post.attachments
        
        self.infoLabel.text = postAttachment[0].contents!["en"] as? String
        
        self.typeLabel.text = String(postAttachment[0].name).capitalizeFirst
        
        self.dateLabel.text = post.createdAt.toTimeFormatInElapsedTimeToString()
    }
    
    func configureCellWithEvent(event: TGEvent!){
        clearLabels()
        
        self.dateLabel.text = event.createdAt.toTimeFormatInElapsedTimeToString()
        
        switch event.type {
            case "like_event":
                self.typeLabel.text = "Likes event"
            case "bookmark_event":
                self.typeLabel.text = "Bookmarked"
            case "tg_friend":
                if event.target.user != nil {
                    self.typeLabel.text = "Friends"
                    self.infoLabel.text = "You are Friends with " + event.target.user.username
                    print(event.target.user.username)
                }
            case "tg_like":
                self.typeLabel.text = "Liked " + event.post.user.username + "'s" + " post"
                self.infoLabel.text = event.post.attachments[0].contents!["en"] as? String
            case "tg_follow":
                if event.target.user != nil {
                    self.typeLabel.text = "Follow"
                    self.infoLabel.text = "You started to follow " + event.target.user.username
                    print(event.target.user.username)
                }
            default: print("More event types then expected")
        }
    }

    func clearLabels(){
        self.typeLabel.text = ""
        self.infoLabel.text = ""
        self.dateLabel.text = ""
    }
}

