//
//  NotificationTableViewCell.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 15/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue

class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var eventTypeImageView: UIImageView!
    
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // TO-DO
    // Clean out custom events
    func configureCellWithEvent(activity: Activity!){
        let activityUser = activity.user?.username
        
        // TODO: Fix to elapsed times
        self.dateLabel.text = activity.createdAt!.toNSDateTime().toTimeFormatInElapsedTimeToString()
        
        switch activity.type! {
        case "tg_friend":
            eventNameLabel.text = activityUser! + " is now friends with " + (activity.targetUser?.username)!
        
            // TODO: Check nil
            // UserImage
            let profileImage = activity.user!.images!["profile"]
            self.eventTypeImageView.kf_setImageWithURL(NSURL(string: profileImage!.url!)!)
        
        case "tg_follow":
            eventNameLabel.text = activityUser! + " is now following " + (activity.targetUser?.username)!
            
            // TODO: Check nil
            // UserImage
            let profileImage = activity.user!.images!["profile"]
            self.eventTypeImageView.kf_setImageWithURL(NSURL(string: profileImage!.url!)!)
        
        case "tg_like":
            self.eventNameLabel.text = activityUser! + " liked a Post"
            self.eventTypeImageView.image = UIImage(named: "LikeFilledRed")
            
        case "tg_comment":
            self.eventNameLabel.text = activityUser! + " commented on your Post"
            self.eventTypeImageView.image = UIImage(named: "ChatFilled")
            
            default: print("Unkown event type")
        }
    }
}
