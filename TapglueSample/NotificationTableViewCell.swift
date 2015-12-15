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

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Configure Cell with TGEvent data
    func configureCellWithEvent(event: TGEvent!){
        
        self.userNameLabel.text = event.user.username
        
        self.eventNameLabel.text = event.type
        
        self.eventTypeImageView.image = UIImage(named: event.type)
        
        let date = event.createdAt
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        self.dateLabel.text = dateFormatter.stringFromDate(date)
        
    }

}
