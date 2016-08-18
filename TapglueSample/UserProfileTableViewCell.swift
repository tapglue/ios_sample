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
    
    func configureCellWithPost(post: Post!){
        clearLabels()
        
        let attachments = post.attachments
        self.infoLabel.text = attachments![0].contents!["en"]
        self.typeLabel.text = String(attachments![0].name!).capitalizeFirst
        
        // OldSDK TODO: show elapsed time
        self.dateLabel.text = post.createdAt
    }
    
    func configureCellWithActivity(activity: Activity!){
        clearLabels()
        
        // OldSDK TODO: show elapsed time
        self.dateLabel.text = activity.createdAt
        
        // OldSDK TODO: fix if event target is available in new sdk
//        switch activity.type! {
//            case "tg_friend":
//                if activity.target.user != nil {
//                    self.typeLabel.text = "Friends"
//                    self.infoLabel.text = "You are Friends with " + activity.target.user.username
//                    print(activity.target.user.username)
//                }
//            case "tg_like":
//                self.typeLabel.text = "Liked " + activity.post.user.username + "'s" + " post"
//                self.infoLabel.text = activity.post.attachments[0].contents!["en"] as? String
//            case "tg_follow":
//                if activity.target.user != nil {
//                    self.typeLabel.text = "Follow"
//                    self.infoLabel.text = "You started to follow " + event.target.user.username
//                    print(activity.target.user.username)
//                }
//            default: print("More event types then expected")
//        }
    }

    func clearLabels(){
        self.typeLabel.text = ""
        self.infoLabel.text = ""
        self.dateLabel.text = ""
    }
}

