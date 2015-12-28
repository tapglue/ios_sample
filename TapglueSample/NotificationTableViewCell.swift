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
    
    // Configure Cell with TGEvent
    func configureCellWithEvent(event: TGEvent!){
        self.userNameLabel.text = event.user.username
        
        self.eventNameLabel.text = event.object.objectId
        
        self.eventTypeImageView.image = UIImage(named: event.type)
        
        // Date to string
        self.dateLabel.text = event.createdAt.toStringFormatHoursMinutes()
    }
    
    
    // Configure Cell with TGEvent
    func configureCellForTypeTGFriend(event: TGEvent!){
        if event.target.user != nil {
            eventNameLabel.text = "You are now friends with " + event.target.user.username
            
            var userImage = TGImage()
            userImage = event.target.user.images.valueForKey("profilePic") as! TGImage
            self.userImageView.downloadedFrom(link: userImage.url, contentMode: .ScaleAspectFill)
            
            
            // Date to string
            self.dateLabel.text = event.createdAt.toStringFormatHoursMinutes()
        }
    }
    
}
