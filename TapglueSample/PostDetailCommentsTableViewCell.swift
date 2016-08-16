//
//  PostDetailCommentsTableViewCell.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 21/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue

class PostDetailCommentsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userCommentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCellWithPostComment(comment: Comment) {
        userNameLabel.text = comment.user?.username
        // OldSDK TODO: Fix comments text
//        userCommentLabel.text = comment.contents["en"] as? String
        
        // OldSDK TODO: Fix to elapsed time
        dateLabel.text = "elapsed time"
        
        // OldSDK TODO: Update to new sdk
//        var userImage = TGImage()
//        userImage = comment.user.images.valueForKey("profilePic") as! TGImage
//        self.userImageView.kf_setImageWithURL(NSURL(string: userImage.url)!)
    }
}

