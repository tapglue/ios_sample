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
        
        let date = event.createdAt
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        self.dateLabel.text = dateFormatter.stringFromDate(date)
    }
    
    
    // Configure Cell with TGEvent
    func configureCellForTypeTGFriend(event: TGEvent!){
        if event.target.user != nil {
            eventNameLabel.text = "You are now friends with " + event.target.user.username
            
            var userImage = TGImage()
            userImage = event.target.user.images.valueForKey("avatar") as! TGImage
            userImageView.image = UIImage(named: userImage.url)
            
            let date = event.createdAt
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "hh:mm"
            self.dateLabel.text = dateFormatter.stringFromDate(date)
        }
    }
    
}
