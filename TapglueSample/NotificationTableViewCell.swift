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
    
    func configureCellWithEvent(activity: Activity!){
        let activityUser = activity.user?.username
        
        // String elapsed times
        self.dateLabel.text = activity.createdAt!.toNSDateTime().toTimeFormatInElapsedTimeToString()
        
        switch activity.type! {
        case "tg_friend":
            if let targetUser = activity.targetUser {
                eventNameLabel.text = activityUser! + " is now friends with " + targetUser.username!
            }
            
            if let profileImages = activity.user?.images {
                self.eventTypeImageView.kf_setImageWithURL(NSURL(string: profileImages["profile"]!.url!)!)
            }
            
        case "tg_follow":
            if let targetUser = activity.targetUser {
                eventNameLabel.text = activityUser! + " is now following " + targetUser.username!
            }
            
            if let profileImages = activity.user?.images {
                self.eventTypeImageView.kf_setImageWithURL(NSURL(string: profileImages["profile"]!.url!)!)
            }
            
        case "tg_like":
            self.eventNameLabel.text = activityUser! + " liked a Post"
            self.eventTypeImageView.image = UIImage(named: "LikeFilledRed")
            
        case "tg_comment":
            self.eventNameLabel.text = activityUser! + " commented on your Post"
            self.eventTypeImageView.image = UIImage(named: "ChatFilled")
            
        default: print("default")
        }
    }
}
