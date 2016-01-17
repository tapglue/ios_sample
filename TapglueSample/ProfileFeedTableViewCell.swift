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
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCellWithPost(post: TGPost!){
        clearLabels()
        
        self.typeLabel.text = post.user.username
        
        self.dateLabel.text = post.createdAt.toTimeFormatInElapsedTimeToString()
        
        // Post attachment
        let postAttachment = post.attachments
        self.infoLabel.text = postAttachment[0].content
    }

    func configureCellWithEvent(event: TGEvent!){
        clearLabels()
        
        self.dateLabel.text = event.createdAt.toTimeFormatInElapsedTimeToString()
        
        switch event.type {
            case "like_event":
                self.typeLabel.text = "Likes Event"
            case "bookmark_event":
                self.typeLabel.text = "Bookmarked"
            case "tg_friend":
                if event.target.user != nil {
                    self.typeLabel.text = "Friends"
                    self.infoLabel.text = "You are Friends with " + event.target.user.username
                    print(event.target.user.username)
                }
            case "tg_like":
                self.typeLabel.text = "Liked " + "'s" + " post"
                
                Tapglue.retrievePostWithId(event.tgObjectId, withCompletionBlock: { (post: TGPost!, error: NSError!) -> Void in
                        if error != nil {
                            print("\nError retrievePostWithId: \(error)")
                        } else {
                            // PostText
                            print(post)
                            let postAttachment = post.attachments
                            self.infoLabel.text = postAttachment[0].content
                        }
                })
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