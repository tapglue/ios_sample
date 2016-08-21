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
        
        let attachments = post.attachments
        self.infoLabel.text = attachments![0].contents!["en"]
        self.typeLabel.text = String(attachments![0].name!).capitalizeFirst
    
        // TODO: Fix to elapsed time
        self.dateLabel.text = post.createdAt!.toNSDateTime().toStringFormatDayMonthYear()
    }

    func configureCellWithEvent(activity: Activity!){
        clearLabels()
        
        self.dateLabel.text = activity.createdAt!.toNSDateTime().toStringFormatDayMonthYear()
        
        let targetUsername = activity.targetUser
        print(targetUsername)
        print("Type: \(activity.type!)")
        print(activity.user?.id!)
        print(activity.post?.user?.username)
        
        switch activity.type! {
        case "tg_friend":
            if activity.targetUser != nil {
                self.typeLabel.text = "Friends"
                self.infoLabel.text = "You are Friends with " + (activity.targetUser?.username!)!
            }
        case "tg_like":
            if activity.post?.user != nil {
                self.typeLabel.text = "Liked " + (activity.post?.user?.username!)! + "'s" + " post"
                self.infoLabel.text = activity.post?.attachments![0].contents!["en"]
            }
        case "tg_follow":
            if activity.targetUser != nil {
                self.typeLabel.text = "Follow"
                self.infoLabel.text = "You started to follow " + (activity.targetUser?.username!)!
            }
        case "tg_comment":
            if activity.post?.user != nil {
                self.typeLabel.text = "Commented"
                self.infoLabel.text = "You commented on " + (activity.post?.user?.username!)! + "'s post"
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
