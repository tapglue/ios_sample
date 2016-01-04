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
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCellWithEvent(event: TGEvent!){
        self.userNameLabel.text = event.user.username
        
        self.eventTypeImageView.image = UIImage(named: event.type)
        
        self.dateLabel.text = event.createdAt.toStringFormatHoursMinutes()
    }
    
    func configureCellForTypeTGFriend(event: TGEvent!){
        if event.target.user != nil {
            eventNameLabel.text = "You are now friends with " + event.target.user.username
            
            var userImage = TGImage()
            userImage = event.target.user.images.valueForKey("profilePic") as! TGImage
            self.userImageView.kf_setImageWithURL(NSURL(string: userImage.url)!)
            
            self.dateLabel.text = event.createdAt.toStringFormatHoursMinutes()
        }
    }
    
}
