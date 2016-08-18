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
        dateLabel.text = comment.createdAt
       
        // TODO: Check nil
        // UserImage
        let profileImage = comment.user?.images!["profile"]
        self.userImageView.kf_setImageWithURL(NSURL(string: profileImage!.url!)!)
    }
}

