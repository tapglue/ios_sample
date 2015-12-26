//
//  NetworkUserTableViewCell.swift
//  TapglueSample
//
//  Created by Onur Akpolat on 25/10/15.
//  Copyright © 2015 Tapglue. All rights reserved.
//

import UIKit
import Tapglue

class NetworkUserTableViewCell: UITableViewCell {

    var cellUser = TGUser()
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
        userImageView.layer.masksToBounds = true
    }
    
    // Configure Cell with TGUser data
    func configureCellWithUser(user: TGUser!){
        cellUser = user
        
        self.userNameLabel.text = self.cellUser.username
        
        var userImage = TGImage()
        userImage = cellUser.images.valueForKey("avatar") as! TGImage
        
        self.userImageView.image = UIImage(named: userImage.url)
        
        if self.connectButton != nil {
            if cellUser.isFriend {
                self.connectButton.selected = true
            } else {
                self.connectButton.selected = false
            }
        }
        
    }
    
    @IBAction func connectPressed(sender: UIButton) {
        if sender.selected {
            
            Tapglue.unfriendUser(cellUser, withCompletionBlock: { (success: Bool,error: NSError!) -> Void in
                if success {
                    print("User unfriend successful")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        sender.selected = false
                    })
                } else if error != nil{
                    print("Error happened\n")
                    print(error)
                }
            })
        } else {
            Tapglue.friendUser(cellUser, withState: TGConnectionState.Pending, withCompletionBlock: { (success : Bool, error : NSError!) -> Void in
                if success {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        sender.selected = true
                        self.connectButton.setTitle("Pending", forState: .Selected)
                    })
                } else if error != nil{
                    print("Error happened\n")
                    print(error)
                }
            })

        }
    }
}
