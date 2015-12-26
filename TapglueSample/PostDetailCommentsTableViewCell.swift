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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCellWithPostComment(comment: TGPostComment) {
        userNameLabel.text = comment.user.username
        userCommentLabel.text = comment.content
        
        var userImage = TGImage()
        userImage = comment.user.images.valueForKey("avatar") as! TGImage
        self.userImageView.image = UIImage(named: userImage.url)
    }
}
