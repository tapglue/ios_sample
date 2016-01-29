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
import TwitterKit
import FBSDKLoginKit
import FBSDKCoreKit

class FindUsersVC: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var currentSelectedNetwork: String!
    
    let contactStore = CNContactStore()
    var contactEmails: [String] = []
    var contacts: [[String:String]] = []
    
    var facebookID: String!
    var twitterID: String!
    
    var users: [TGUser] = []
    
    var fromUsers: [TGUser] = []
    var toUsers: [TGUser] = []
    
    // Arr of FacebookFriends
    var friendsFromFacebook: [AnyObject]? = []
    
    var followsFromTwitter: [String]? = []
    
    let facebookLogInButton = FBSDKLoginButton()
    
    var twitterLogInButton = TWTRLogInButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("find friends")
        
        configureFacebook()
        
        switch currentSelectedNetwork {
            case "Contacts":
                self.searchForUserByEmail()
            case "Recommendations":
                self.getRecommendedUsers()
            case "Facebook":
                let facebookPermission = defaults.objectForKey("facebookPermission") as! Bool
                
                if facebookPermission {
                    print("facebookPermissionGranted")
                    self.returnUserFriendsData()
                } else {
                    // Show facebookLoginButton
                    facebookLogInButton.frame = CGRectMake(self.view.frame.size.width / 2 - 100, self.view.frame.size.height / 2 - 25, 200, 50)
                    facebookLogInButton.layer.masksToBounds = true
                    facebookLogInButton.layer.cornerRadius = 4
                    self.view.addSubview(facebookLogInButton)
                }
            case "Twitter":
                // get default checked array
                let twitterPermission = defaults.objectForKey("twitterPermission") as! Bool
                
                if twitterPermission {
                    print("twitterPermissionGranted")
                    self.getTwitterFriends(-1)
                } else {
                    // Show twitterLoginButton
                    twitterLogInButton.frame = CGRectMake(self.view.frame.size.width / 2 - 100, self.view.frame.size.height / 2 - 25, 200, 50)
                    twitterLogInButton.addTarget(self, action: "twitterLoginPressed:", forControlEvents: .TouchUpInside)
                    self.view.addSubview(twitterLogInButton)
                }
            default: print("More then expected switches")
        }
    }
    
    func twitterLoginPressed(sender: TWTRLogInButton!) {
        self.twitterLogin()
    }
 
    // SearchForUserByEmail and reload tableview if user was found
    func searchForUserByEmail() {
        readAddressBookByEmail()
        
        Tapglue.searchUsersWithEmails(contactEmails) { (users: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                print("\nError searchUsersWithEmails: \(error)")
            }
            else {
                print("\nSuccessful searchUsersWithEmails: \(users)")
                self.users = users as! [TGUser]
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.reloadTableViewWithAnimation()
                })
            }
        }
    }
    
    // Retrieve User Recommendations
    func getRecommendedUsers() {
        Tapglue.retrieveUserRecommendationsWithCompletionBlock { (users: [AnyObject]!, error : NSError!) -> Void in
            if error != nil {
                print("\nError retrieveUserRecommendations: \(error)")
            }
            else {
                print(users)
                print("\nSuccessful retrieveUserRecommendations: \(users)")
                self.users = users as! [TGUser]
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.reloadTableViewWithAnimation()
                })
            }
        }
    }
    
    // ReadAddressBookByEmail and saving contacts in dicionary
    func readAddressBookByEmail(){
        do {
            try contactStore.enumerateContactsWithFetchRequest(CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey])) {
                (contact, cursor) -> Void in
                if (!contact.emailAddresses.isEmpty){
                    var itemCount = 0
                    for item in contact.emailAddresses {
                        itemCount++
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
                    
                    // add friends that are found
                    Tapglue.searchUsersOnSocialPlatform(TGPlatformKeyFacebook, withSocialUsersIds: self.friendsFromFacebook, andCompletionBlock: { (facebookUsers: [AnyObject]!, error: NSError!) -> Void in
                        if error != nil {
                            print("\nError searchUsersOnSocialPlatform: \(error)")
                        }
                        else {
                            print("\nSuccessful-facebook friends: \(facebookUsers)")
                            
                            self.users.removeAll(keepCapacity: false)
                            self.users = facebookUsers as! [TGUser]
                            
                            self.users.sortInPlace({ (contact1, contact2) -> Bool in
                                return contact1.username < contact2.username
                            })
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.facebookLogInButton.hidden = true
                                
                                self.reloadTableViewWithAnimation()
                            })
                        }
                    })
                }
            })
        }
    }
    
    // Mark: -Twitter Methods
    func twitterLogin(){
        Twitter.sharedInstance().logInWithCompletion { (session: TWTRSession?, error: NSError?) -> Void in
            if (session != nil) {
                print("signed in as: \(session!.userName)")
                print("signed in as: \(session!.userID)")
                print("signed in as: \(session!)")
                
                self.twitterID = session!.userID
                
                // update TGUser social id from twitter
                let currentUser = TGUser.currentUser()
                currentUser.setSocialId(self.twitterID, forKey: TGPlatformKeyTwitter)
                currentUser.saveWithCompletionBlock({ (success: Bool, error: NSError!) -> Void in
                    print(success)
                })
                
                // Bool to check if user granted permission for twitter
                self.defaults.setObject(true, forKey: "twitterPermission")
                
                self.getTwitterFriends(-1)
            } else {
                print("error: \(error!.localizedDescription)")
            }
        }
    }
    
    func getTwitterFriends(nextCursor: Int){
        var clientError:NSError?
        let params: Dictionary = Dictionary<String, String>()
        
        var cursorNext = nextCursor
        
        let urlTwitterApi: String = "https://api.twitter.com/1.1/friends/ids.json?cursor=" + String(nextCursor) + "&count=5000"
        
        let request: NSURLRequest! = Twitter.sharedInstance().APIClient.URLRequestWithMethod(
            "GET",
            URL: urlTwitterApi,
            parameters: params,
            error: &clientError)
        
        if request != nil {
            Twitter.sharedInstance().APIClient.sendTwitterRequest(request!) {
                (response, data, connectionError) -> Void in
                if (connectionError == nil) {
                    let json: AnyObject? = try!
                        NSJSONSerialization.JSONObjectWithData(data!,
                            options: .MutableContainers)
                    
                    // check for json data
                    if (json != nil) {
                        let resultdict = json as! NSDictionary
                        
                        cursorNext = resultdict.objectForKey("next_cursor") as! Int
                        print("NextCursor: \(cursorNext)")
                        
                        let data: NSArray = resultdict.objectForKey("ids") as! NSArray
                        print("Result Data: \(data)")
                        
                        for id in data {
                            self.followsFromTwitter?.append(String(id))
                        }
                        
                        if cursorNext != 0 {
                            self.getTwitterFriends(cursorNext)
                        } else {
                            // Handle all follower twitter ids at once
                            self.twitterFollowersSliceAndCheckWithTapglue(self.followsFromTwitter!)
                        }
                    } else {
                        print("error loading json data")
                    }
                }
                else {
                    print("Error: \(connectionError)")
                }
            }
        }
        else {
            print("Error: \(clientError)")
        }
    }
    
    func twitterFollowersSliceAndCheckWithTapglue(arr: [String]) {
        // Split all followers in 495 array pieces and Check if twitterFriends are availabe in your App
        var followers = arr
        var tempArrOfFollowers = [[String]]()
        
        while followers.count > 495 {
            let sliceArr = followers[0...495]
            let tempArray: [String] = Array(sliceArr)
            tempArrOfFollowers.append(tempArray)
            followers.removeRange(0...495)
        }
        
        let sliceArr = self.followsFromTwitter![0...(followers.count - 1)]
        let tempArray: [String] = Array(sliceArr)
        tempArrOfFollowers.append(tempArray)
        followers.removeRange(0...(followers.count - 1))
        
        print("Sliced Arr: \(tempArrOfFollowers.count)")
        
        // Check and add twitterFriends
        if self.followsFromTwitter != nil {
            var twitterUsersArr = [TGUser]()
            for followerIDs in tempArrOfFollowers {
                // Check if twitterFriends are availabe in your App
                Tapglue.searchUsersOnSocialPlatform(TGPlatformKeyTwitter, withSocialUsersIds: followerIDs, andCompletionBlock: { (twitterUsers: [AnyObject]!, error: NSError!) -> Void in
                    if error != nil {
                        print("\nError searchUsersOnSocialPlatform: \(error)")
                    }
                    else {
                        print("\nSuccessful - twitterFriends: \(twitterUsers)")
                        
                        for user in twitterUsers {
                            twitterUsersArr.append(user as! TGUser)
                        }
                        
                        self.users = twitterUsersArr
                        
                        self.users.sortInPlace({ (contact1, contact2) -> Bool in
                            return contact1.username < contact2.username
                        })
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.twitterLogInButton.hidden = true
                            
                            self.reloadTableViewWithAnimation()
                        })
                    }
                })
            }
            

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
            case "Twitter":
                return users.count
            case "Recommendations":
                return users.count
            default: return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FindUsersTableViewCell
        
        switch currentSelectedNetwork {
            case "Contacts":
                print("checkingForContacts")
                
                for usr in users {
                    let tempContact = contacts[indexPath.row]
                    if usr.email == tempContact["email"] {
                        print("true")
                        cell.configureCellWithUserFromContactsThatUsesApp(contacts[indexPath.row], user: usr)
                    } else {
                        cell.configureCellWithUserFromContacts(contacts[indexPath.row])
                    }
                }

            case "Facebook":
                let user = self.users[indexPath.row]
                cell.configureCellWithUserToFriendOrFollow(user)

            case "Twitter":
                let user = self.users[indexPath.row]
                cell.configureCellWithUserToFriendOrFollow(user)
            
            case "Recommendations":
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
                
                // Init CurrentUser
                let currentUser = TGUser.currentUser()
                
                // Get facebook about and at to currentUserMetadata
                if result.objectForKey("bio") != nil {
                    let about: [NSObject : AnyObject!] = ["about" : (result.objectForKey("bio") as? String)!]
                    currentUser.metadata = about
                }
                // Add Facebook ImageURL to currentUser
                let userImage = TGImage()
                userImage.url = "https://graph.facebook.com/\(self.facebookID)/picture?type=large"
                currentUser.images.setValue(userImage, forKey: "profilePic")
                // Add socialID to currentUser
                currentUser.setSocialId(self.facebookID, forKey: TGPlatformKeyFacebook)
                // Update currentUser
                currentUser.saveWithCompletionBlock({ (success: Bool, error: NSError!) -> Void in
                    print(success)
                })
            }
            
        }
        returnUserFriendsData()
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
    }
}
