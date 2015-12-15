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
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Configure Cell with TGEvent data
    func configureCellWithPost(post: TGPost!){
        
        self.userName.text = post.user.username
        
        // PostText
        let postAttachment = post.attachments
        self.typeLabel.text = postAttachment[0].name
    }

    // Configure Cell with TGEvent data
    func configureCellWithEvent(event: TGEvent!){
        
        self.userName.text = event.user.username

        self.typeLabel.text = event.type
    }

}
