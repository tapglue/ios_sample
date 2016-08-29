//
//  FindUsersVC.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 04/01/16.
//  Copyright © 2016 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue
import Contacts
import FBSDKLoginKit
import FBSDKCoreKit

class FindUsersVC: UIViewController, UITableViewDelegate {
    
    let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var currentSelectedNetwork: String!
    
    let contactStore = CNContactStore()
    var contactEmails: [String] = []
    var contacts: [[String:String]] = []
    
    var facebookID: String!
    
    var users: [User] = []
    
    var fromUsers: [User] = []
    var toUsers: [User] = []
    
    // Arr of FacebookFriends
    var friendsFromFacebook: [AnyObject]? = []
    
    let facebookLogInButton = FBSDKLoginButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureFacebook()
        
        switch currentSelectedNetwork {
            case "Contacts":
                self.searchForUserByEmail()
            case "Facebook":
                let facebookPermission = defaults.objectForKey("facebookPermission") as! Bool
                
                if facebookPermission {
                    self.returnUserFriendsData()
                } else {
                    // Show facebookLoginButton
                    facebookLogInButton.frame = CGRectMake(self.view.frame.size.width / 2 - 100, self.view.frame.size.height / 2 - 25, 200, 50)
                    facebookLogInButton.layer.masksToBounds = true
                    facebookLogInButton.layer.cornerRadius = 4
                    self.view.addSubview(facebookLogInButton)
                }
            default: print("More then expected switches")
        }
    }
 
    // SearchForUserByEmail and reload tableview if user was found
    func searchForUserByEmail() {
        readAddressBookByEmail()
        
        appDel.rxTapglue.searchEmails(contactEmails).subscribe { (event) in
            switch event {
            case .Next(let usr):
                print("Next")
                self.users = usr
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Do the action")
                dispatch_async(dispatch_get_main_queue()) {
                    // TO-DO delete animation if not needed
                    //                    self.reloadTableViewWithAnimation()
                    self.friendsTableView.reloadData()
                }
            }
        }.addDisposableTo(self.appDel.disposeBag)
    }
    
    // ReadAddressBookByEmail and saving contacts in dicionary
    func readAddressBookByEmail(){
        do {
            try contactStore.enumerateContactsWithFetchRequest(CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey])) {
                (contact, cursor) -> Void in
                if (!contact.emailAddresses.isEmpty){
                    print(contact)
                    var itemCount = 0
                    for item in contact.emailAddresses {
                        itemCount += 1
                        if itemCount <= 1 {
                            self.contacts.append(["givenName": contact.givenName, "email" : String(item.value)])
                            self.contactEmails.append(String(item.value))
                        }
                    }
                }
                
                // Sort Contacts by GivenName
                self.contacts.sortInPlace({ (contact1, contact2) -> Bool in
                    return contact1["givenName"] < contact2["givenName"]
                })
            }
        }
        catch{
            print("Handle the error please")
        }
    }
    
    // Return facebook friends to tapglue
    func returnUserFriendsData(){
        if (FBSDKAccessToken.currentAccessToken() != nil){
            let friendsRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/friends?fields=id", parameters: nil)
            friendsRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                if ((error) != nil){
                    // error
                    print("Error: \(error)")
                    print("Connection: \(connection)")
                } else {
                    let resultdict = result as! NSDictionary
                    let data: NSArray = resultdict.objectForKey("data") as! NSArray
                    
                    for i in 0 ..< data.count
                    {
                        let valueDict: NSDictionary = data[i] as! NSDictionary
                        let id = valueDict.objectForKey("id") as! String
                        
                        print("Friend id value is \(id)")
                        
                        // save facebook friend ids inside AnyObject array
                        self.friendsFromFacebook?.append(id)
                    }
                    
                    // OldSDK - TODO: FacebookTODO and TapglueFindFriends
                    // add friends that are found
//                    Tapglue.searchUsersOnSocialPlatform(TGPlatformKeyFacebook, withSocialUsersIds: self.friendsFromFacebook, andCompletionBlock: { (facebookUsers: [AnyObject]!, error: NSError!) -> Void in
//                        if error != nil {
//                            print("\nError searchUsersOnSocialPlatform: \(error)")
//                        }
//                        else {
//                            print("\nSuccessful-facebook friends: \(facebookUsers)")
//                            
//                            self.users.removeAll(keepCapacity: false)
//                            self.users = facebookUsers as! [TGUser]
//                            
//                            self.users.sortInPlace({ (contact1, contact2) -> Bool in
//                                return contact1.username < contact2.username
//                            })
//                            
//                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                                self.facebookLogInButton.hidden = true
//                                
//                                self.reloadTableViewWithAnimation()
//                            })
//                        }
//                    })
                }
            })
        }
    }
    
}

extension FindUsersVC: UITableViewDataSource {
    // MARK: - TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentSelectedNetwork {
            case "Contacts":
                return contacts.count
            case "Facebook":
                return users.count
            default: return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FindUsersTableViewCell
        
        switch currentSelectedNetwork {
            case "Contacts":
                
                // Show users that use the app in the right cell
                for usr in users {
                    let tempContact = contacts[indexPath.row]
                    
                    if usr.email == tempContact["email"] {
                        cell.configureCellWithUserFromContactsThatUsesApp(contacts[indexPath.row], user: usr)
                        break
                    } else {
                        cell.configureCellWithUserFromContacts(contacts[indexPath.row])
                    }
                }

            case "Facebook":
                let user = self.users[indexPath.row]
                cell.configureCellWithUserToFriendOrFollow(user)
            
        default: print("more then expected segments")
        }
        
        return cell
    }
    
    func reloadTableViewWithAnimation() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.transitionWithView(self.friendsTableView,
                duration:0.1,
                options:.TransitionCrossDissolve,
                animations:
                { () -> Void in
                    self.friendsTableView.reloadData()
                },
                completion: nil);
        })
    }
}

extension FindUsersVC: FBSDKLoginButtonDelegate {
    // Mark: -Facebook Methods
    func configureFacebook(){
        facebookLogInButton.readPermissions = ["public_profile", "email", "user_friends", "user_about_me"];
        facebookLogInButton.delegate = self
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, last_name, picture.type(large), id, bio"]).startWithCompletionHandler { (connection, result, error) -> Void in
            
            if error != nil{
                print(error)
            } else {
                self.facebookID = (result.objectForKey("id") as? String)!
                print(self.facebookID)
                
                self.defaults.setObject(true, forKey: "facebookPermission")
                
                print("https://graph.facebook.com/\(self.facebookID)/picture?type=large")
                
//                // Init CurrentUser
//                let currentUser = self.appDel.rxTapglue.currentUser!
                
                
                // OldSDK - TODO: FacebookTODO
//                // Get facebook about and at to currentUserMetadata
//                if result.objectForKey("bio") != nil {
//                    let about: [NSObject : AnyObject!] = ["about" : (result.objectForKey("bio") as? String)!]
//                    currentUser.metadata = about
//                }
//                // Add Facebook ImageURL to currentUser
//                let userImage = TGImage()
//                userImage.url = "https://graph.facebook.com/\(self.facebookID)/picture?type=large"
//                currentUser.images.setValue(userImage, forKey: "profilePic")
//                // Add socialID to currentUser
//                currentUser.setSocialId(self.facebookID, forKey: TGPlatformKeyFacebook)
//                // Update currentUser
//                currentUser.saveWithCompletionBlock({ (success: Bool, error: NSError!) -> Void in
//                    print(success)
//                })
            }
            
        }
        returnUserFriendsData()
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
    }
}
