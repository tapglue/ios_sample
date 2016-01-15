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
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCellWithEvent(event: TGEvent!){
        let eventUser = event.user.username
        
        self.userNameLabel.text = eventUser
        self.dateLabel.text = event.createdAt.toTimeFormatInElapsedTimeToString()
        
        switch event.type {
            case "tg_friend":
                eventNameLabel.text = eventUser + " is now friends with " + event.target.user.username
                
                if let userImage = event.target.user.images.valueForKey("profilePic") as! TGImage? {
                    self.eventTypeImageView.kf_setImageWithURL(NSURL(string: userImage.url)!)
                }
            
            case "tg_follow":
                eventNameLabel.text = eventUser + " is now following " + event.target.user.username
                
                if let userImage = event.target.user.images.valueForKey("profilePic") as! TGImage? {
                    self.eventTypeImageView.kf_setImageWithURL(NSURL(string: userImage.url)!)
                }
            
            case "tg_like":
                self.eventNameLabel.text = eventUser + " liked a Post"
                self.eventTypeImageView.image = UIImage(named: "LikeFilledRed")
            
            case "like_event":
                self.eventNameLabel.text = eventUser + " liked an Article"
                self.eventTypeImageView.image = UIImage(named: event.type)
            
            case "bookmark_event":
                self.eventNameLabel.text = eventUser + " bookmarked an Article"
                self.eventTypeImageView.image = UIImage(named: event.type)
            
            default: print("Unkown event type")
        }
        
        
    }
}
