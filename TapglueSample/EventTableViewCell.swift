//
//  EventTableViewCell.swift
//  TapglueSample
//
//  Created by Onur Akpolat on 24.10.15.
//  Copyright © 2015 Tapglue. All rights reserved.
//

import UIKit
import Tapglue

class EventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var eventUserNameLabel: UILabel!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventCreatedLabel: UILabel!
    
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Customize the layout of the userImageView
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
        userImageView.layer.masksToBounds = true
    }
    
    // Configure Cell with TGEvent data
    func configureCellWithEvent(event: TGEvent!){
        self.eventUserNameLabel.text = event.user.username
        
        var eventText = String()
        
        if event.type == "tg_friend" {
            self.eventImageView.image = UIImage(named: "Friendship")
            if event.target.objectId == TGUser.currentUser().objectId {
                eventText = "is now your friend"
            } else {
                eventText = "just friended another user"
            }
            
        } else {
            eventText = event.type
        }
        self.eventNameLabel.text = eventText
        
        var userImage = TGImage()
        userImage = event.user.images.valueForKey("avatar") as! TGImage;

        self.userImageView.image = UIImage(named: userImage.url)
        
        if event.object != nil {
            self.eventImageView.image = UIImage(named: event.object.objectId)
        }
        
        let date = event.createdAt
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        self.eventCreatedLabel.text = dateFormatter.stringFromDate(date)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}