//
//  EditProfilTableViewCell.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 14/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue

class EditProfilTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var userInfoTitleLabel: UILabel!
    @IBOutlet weak var userInfoEditTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        userInfoEditTextField.delegate = self
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Mark: - TextField methods
    func textFieldDidEndEditing(textField: UITextField) {
        changeTGUserInformation(textField)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        changeTGUserInformation(textField)
        
        textField.resignFirstResponder()
        
        return false
    }
    
    
    func changeTGUserInformation(tf: UITextField){
        switch tf.tag {
        case 0:
            TGUser.currentUser().username = tf.text!
        case 1:
            TGUser.currentUser().firstName = tf.text!
        case 2:
            TGUser.currentUser().lastName = tf.text!
        case 3:
            print("not changin about")
        case 4:
            TGUser.currentUser().email = tf.text!
        default: print("More then expected switches")
        }
    }
    
}
