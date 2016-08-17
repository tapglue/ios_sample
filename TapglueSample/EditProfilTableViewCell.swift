//
//  EditProfilTableViewCell.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 14/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue

class EditProfilTableViewCell: UITableViewCell {
    
    // Get the AppDelegate
    let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate

    @IBOutlet weak var userInfoTitleLabel: UILabel!
    @IBOutlet weak var userInfoEditTextField: UITextField!
    
    var currentUser: User!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userInfoEditTextField.delegate = self
        
        currentUser = appDel.rxTapglue.currentUser!
    }
    
    func changeUserInformation(tf: UITextField){
        switch tf.tag {
            case 0:
                currentUser.username = tf.text!
            case 1:
                currentUser.firstName = tf.text!
            case 2:
                currentUser.lastName = tf.text!
            case 3:
                // OldSDK
                print("Fix if about available")
//                let about: [NSObject : AnyObject!] = ["about" : tf.text!]
//                TGUser.currentUser().metadata = about
            case 4:
                currentUser.email = tf.text!
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
