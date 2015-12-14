//
//  EditProfilTableViewCell.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 14/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit

class EditProfilTableViewCell: UITableViewCell {

    @IBOutlet weak var userInfoTitleLabel: UILabel!
    @IBOutlet weak var userInfoEditTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
