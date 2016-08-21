//
//  EditProfilTableViewCell.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 14/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue

// the name of the protocol you can put any
protocol UpdateUserDelegate {
    func updateUsername(tf: UITextField)
    func updateFirstname(tf: UITextField)
    func updateLastname(tf: UITextField)
    func updateAbout(tf: UITextField)
    func updateEmail(tf: UITextField)
}

class EditProfilTableViewCell: UITableViewCell {

    @IBOutlet weak var userInfoTitleLabel: UILabel!
    @IBOutlet weak var userInfoEditTextField: UITextField!
    
    var delegate: UpdateUserDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userInfoEditTextField.delegate = self
    }
    
    func changeUserInformation(tf: UITextField){
        switch tf.tag {
            case 0:
                delegate?.updateUsername(tf)
            case 1:
                delegate?.updateFirstname(tf)
            case 2:
                delegate?.updateLastname(tf)
            case 3:
                delegate?.updateAbout(tf)
            case 4:
                delegate?.updateEmail(tf)
            default: print("More then expected switches")
        }
    }
}

extension EditProfilTableViewCell: UITextFieldDelegate {
    // Mark: - TextField
    func textFieldDidEndEditing(textField: UITextField) {
        changeUserInformation(textField)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        changeUserInformation(textField)
        
        textField.resignFirstResponder()
        
        return false
    }
}
