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
        self.dateLabel.text = "activity createdAt needed"
        
        switch activity.type! {
            case "tg_friend":
                eventNameLabel.text = activityUser! + " is now friends with " + " fix activity.target.user.username"
            
                //Old SDK
//                if let userImage = activity.target.user.images.valueForKey("profilePic") as! TGImage? {
//                    self.eventTypeImageView.kf_setImageWithURL(NSURL(string: userImage.url)!)
//                }
            
            case "tg_follow":
                eventNameLabel.text = activityUser! + " is now following " + " fix activity.target.user.username"
            
                //Old SDK
//                if let userImage = activity.target.user.images.valueForKey("profilePic") as! TGImage? {
//                    self.eventTypeImageView.kf_setImageWithURL(NSURL(string: userImage.url)!)
//                }
            
            case "tg_like":
                self.eventNameLabel.text = activityUser! + " liked a Post"
                self.eventTypeImageView.image = UIImage(named: "LikeFilledRed")
            
            default: print("Unkown event type")
        }
    }
}
