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
        userCommentLabel.text = comment.contents!["en"]
        
        // OldSDK TODO: Fix to elapsed time
        dateLabel.text = comment.createdAt!.toNSDateTime().toStringFormatDayMonthYear()
       
        // TODO: Check nil
        // UserImage
        if let profileImages = comment.user?.images {
            self.userImageView.kf_setImageWithURL(NSURL(string: profileImages["profile"]!.url!)!)
        }
    }
}

