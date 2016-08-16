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
    
    // Get the AppDelegate
    let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCellWithPost(post: Post!){
        clearLabels()
        
        // OldSDK dies
//        // Post attachment
//        let postAttachment = post.attachments
//        
//        self.infoLabel.text = postAttachment[0].contents!["en"] as? String
//        
//        self.typeLabel.text = String(postAttachment[0].name).capitalizeFirst
    
        // TODO: Fix to elapsed time
        self.dateLabel.text = post.createdAt!
    }

    func configureCellWithEvent(activity: Activity!){
        clearLabels()
        
        // OldSDK TODO: Fix to elapsed time
        self.dateLabel.text = "elapsed time coming"
        
        // OldSDK TODO: Fix after old event target user is available in the new sdk
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
//                    self.infoLabel.text = "You started to follow " + activity.target.user.username
//                    print(event.target.user.username)
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
