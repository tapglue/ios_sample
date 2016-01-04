//
//  NetworkVC.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 21/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue
import Contacts
import TwitterKit
import FBSDKLoginKit
import FBSDKCoreKit

class NetworkVC: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var networkButton: UIButton!
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    @IBOutlet weak var networkSegmentedControl: UISegmentedControl!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var users: [TGUser] = []
    
    var fromUsers: [TGUser] = []
    var toUsers: [TGUser] = []
    
    var resultSearchController: UISearchController!
    
    let contactStore = CNContactStore()
    var contactEmails: [String] = []
    var contacts: [[String:String]] = [[:]]
    
    var facebookID: String!
    var twitterID: String!
    
    // Arr of FacebookFriends
    var friendsFromFacebook: [AnyObject]? = []
    
    let facebookLogInButton = FBSDKLoginButton()
    
    var twitterLogInButton = TWTRLogInButton()
    
    var checkingForPendingConnections = false
    
    var currentSegmentedControl = "pending"
    
//    var sections = ["Find Friends", "My Pending", "Outside Pending"]
    var networks = ["Contacts", "Facebook", "Twitter"]

    override func viewDidLoad() {
        super.viewDidLoad()
        checkForPendingConnections()
        configureFacebook()

        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            self.friendsTableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        // Reload the TableView
        reloadTableViewWithAnimation()
        
        // hide Newtwork button
        networkButton.hidden = true
        
        twitterLogInButton = TWTRLogInButton(logInCompletion: { session, error in
            if (session != nil) {
                print("signed in as \(session!.userName)")
                self.twitterLogin()
            } else {
                print("error: \(error!.localizedDescription)")
            }
        })
        
        // Setup searchBar
        resultSearchController.searchResultsUpdater = self
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.dimsBackgroundDuringPresentation = false
        resultSearchController.searchBar.sizeToFit()
        resultSearchController.searchBar.placeholder = "Username search"
        self.friendsTableView.tableHeaderView = resultSearchController.searchBar
    }
    
    override func viewWillAppear(animated: Bool) {
        self.resultSearchController.searchBar.hidden = false

    }
    
    override func viewWillDisappear(animated: Bool) {
        self.resultSearchController.searchBar.hidden = true
        self.resultSearchController.active = false
    }
    
    @IBAction func networkButtonPressed(sender: UIButton) {
        switch networkSegmentedControl.selectedSegmentIndex {
            case 0:
                print("Pending")
            
            case 1:
                print("Contacts")
                defaults.setObject(true, forKey: "contactsPermission")
                searchForUserByEmail()
            
            case 2:
                print("Facebook")
            
            case 3:
                print("Twitter")
            
            default: print("More segments then expected")
        }
    }
    
    @IBAction func networkSegmentedChanged(sender: UISegmentedControl) {
        // Set all buttons to hidden
        twitterLogInButton.hidden = true
        facebookLogInButton.hidden = true
        networkButton.hidden = true
        
        switch networkSegmentedControl.selectedSegmentIndex {
            case 0:
                currentSegmentedControl = "pending"
                clearUsersArrayAndReloadTableView()
                checkForPendingConnections()
                friendsTableView.tableHeaderView = resultSearchController.searchBar
                self.resultSearchController.active = true
            
            case 1:
                currentSegmentedControl = "contacts"
                clearUsersArrayAndReloadTableView()
                outsidePendingSegment()
                contactsSegmentWasPicked()
            
            case 2:
                currentSegmentedControl = "facebook"
                clearUsersArrayAndReloadTableView()
                outsidePendingSegment()
                facebookSegmentWasPicked()
            
            case 3:
                currentSegmentedControl = "twitter"
                clearUsersArrayAndReloadTableView()
                outsidePendingSegment()
                twitterSegmentWasPicked()
            

            default: print("Segments index wrong")
        }
    }
    
    // Checking for pending connections
    func pendingSegmentWasPicked(){
        checkForPendingConnections()
    }
    
    // Contacts Permission check if granted search for friends and reload TableView
    func contactsSegmentWasPicked(){
        // get default checked array
        let contactPermission = defaults.objectForKey("contactsPermission") as! Bool
        print(contactPermission)
        
        if contactPermission {
            print("contactPermissionGranted")
            self.networkButton.hidden = true
            self.searchForUserByEmail()
        } else {
            self.networkButton.hidden = false
            self.networkButton.setTitle("Contacts", forState: .Normal)
            self.networkButton.backgroundColor = UIColor.brownColor()
        }
    }
    
    // Facebook Permission check if granted search for friends and reload TableView
    func facebookSegmentWasPicked(){
        // get default checked array
        let facebookPermission = defaults.objectForKey("facebookPermission") as! Bool
        print(facebookPermission)
        
        if facebookPermission {
            print("facebookPermissionGranted")
            self.facebookLogInButton.hidden = true
            self.returnUserFriendsData()
        } else {
            // Show facebookLoginButton
            facebookLogInButton.hidden = false
            facebookLogInButton.frame = CGRectMake(self.view.frame.size.width / 2 - 100, self.view.frame.size.height / 2 - 25, 200, 50)
            facebookLogInButton.layer.masksToBounds = true
            facebookLogInButton.layer.cornerRadius = 4
            self.view.addSubview(facebookLogInButton)
        }
    }
    
    // Twitter Permission check if granted search for friends and reload TableView
    func twitterSegmentWasPicked(){
        // get default checked array
        let twitterPermission = defaults.objectForKey("twitterPermission") as! Bool
        
        if twitterPermission {
            print("twitterPermissionGranted")
            self.networkButton.hidden = true
            self.getTwitterFriends(-1)
        } else {
            // Show twitterLoginButton
            twitterLogInButton.hidden = false
            twitterLogInButton.frame = CGRectMake(self.view.frame.size.width / 2 - 100, self.view.frame.size.height / 2 - 25, 200, 50)
            self.view.addSubview(twitterLogInButton)
        }
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
                    self.networkButton.hidden = true
                    
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
                //                self.client = TWTRAPIClient(userID: session!.userID)
                // make requests with client
                //                    print(self.client.userID)
                
                // update TGUser social id from twitter
                let currentUser = TGUser.currentUser()
                currentUser.setSocialId(self.twitterID, forKey: TGPlatformKeyTwitter)
                currentUser.saveWithCompletionBlock({ (success: Bool, error: NSError!) -> Void in
                    print(success)
                })
                
                // TO-DO: uncomment
                // Bool to check if user granted permission for twitter
//                self.defaults.setObject(true, forKey: "twitterPermission")
                
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
        
        let urlTwitterApi: String = "https://api.twitter.com/1.1/friends/ids.json?cursor=" + String(nextCursor) + "&count=499"
        
        let request: NSURLRequest! = Twitter.sharedInstance().APIClient.URLRequestWithMethod(
            "GET",
            URL: urlTwitterApi,
            parameters: params,
            error: &clientError)
        
        var followsFromTwitter: [String]? = []
        
        if request != nil {
            Twitter.sharedInstance().APIClient.sendTwitterRequest(request!) {
                (response, data, connectionError) -> Void in
                if (connectionError == nil) {
                    var jsonError: NSError?
                    let json: AnyObject? = try!
                        NSJSONSerialization.JSONObjectWithData(data!,
                            options: .MutableContainers)
                    
                    // check for json data
                    if (json != nil) {
                        // print("response = \(json)")
                        // print(json?.valueForKey("ids"))
                        
                        let resultdict = json as! NSDictionary
                        // print("Result Dict: \(resultdict)")
                        
                        cursorNext = resultdict.objectForKey("next_cursor") as! Int
                        print("NextCursor: \(cursorNext)")
                        
                        let data: NSArray = resultdict.objectForKey("ids") as! NSArray
                         print("Result Data: \(data)")
                        
                        for id in data {
                            followsFromTwitter?.append(String(id))
                        }
                        
                        // Check and add twitterFriends
                        if followsFromTwitter != nil {
                            // Check if twitterFriends are availabe in your App
                            Tapglue.searchUsersOnSocialPlatform(TGPlatformKeyTwitter, withSocialUsersIds: followsFromTwitter, andCompletionBlock: { (twitterUsers: [AnyObject]!, error: NSError!) -> Void in
                                if error != nil {
                                    print("\nError searchUsersOnSocialPlatform: \(error)")
                                }
                                else {
                                    print("\nSuccessful - twitterFriends: \(twitterUsers)")
                                    
                                    self.users.removeAll(keepCapacity: false)
                                    self.users = twitterUsers as! [TGUser]
                                    
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
                        
                        print(followsFromTwitter!.count)
                        
                        if cursorNext != 0 {
                            self.getTwitterFriends(cursorNext)
                        }
                    } else {
                        print("error loading json data = \(jsonError)")
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
    
    func clearUsersArrayAndReloadTableView(){
        self.fromUsers.removeAll(keepCapacity: false)
        self.toUsers.removeAll(keepCapacity: false)
        self.users.removeAll(keepCapacity: false)
        self.contacts.removeAll(keepCapacity: false)
        self.contactEmails.removeAll(keepCapacity: false)
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.friendsTableView.reloadData()
        })
    }
    
    func checkForPendingConnections(){
        checkingForPendingConnections = true
        
        Tapglue.retrievePendingConncetionsForCurrentUserWithCompletionBlock { (incoming: [AnyObject]!, outgoing: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                print("\nError retrievePendingConncetionsForCurrentUser: \(error)")
            } else {
                print("\nSuccess")
                print(incoming)
                print(outgoing)

                for inc in incoming {
                    self.fromUsers.append((inc as! TGConnection).fromUser)
                }
                for out in outgoing {
                    self.toUsers.append((out as! TGConnection).toUser)
                }
                print("\nFrom: \(self.fromUsers)")
                print("\nTo: \(self.toUsers)")
                
                self.users = self.fromUsers
                
                self.users.sortInPlace({ (contact1, contact2) -> Bool in
                    return contact1.username < contact2.username
                })
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.facebookLogInButton.hidden = true
                    
                    self.reloadTableViewWithAnimation()
                })
            }
        }
    }
    
    func outsidePendingSegment() {
        self.checkingForPendingConnections = false
        friendsTableView.tableHeaderView = nil
        self.resultSearchController.active = false
    }
}

extension NetworkVC: UITableViewDataSource {
    // Mark: -TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentSegmentedControl {
        case "pending":
            return self.users.count
        case "contacts":
            return self.contacts.count
        case "facebook":
            return self.users.count
        case "twitter":
            return self.users.count
        default: return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NetworkUserTableViewCell
        
        cell.userImageView.image = nil
        
        switch currentSegmentedControl {
            case "pending":
                let user = self.users[indexPath.row]
                cell.checkingForPendingConnections = true
                cell.configureCellWithUserWithPendingConnection(user)
            
            case "contacts":
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
            
            case "facebook":
                let user = self.users[indexPath.row]
                cell.configureCellWithUserToFriendOrFollow(user)
            
            case "twitter":
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

extension NetworkVC: FBSDKLoginButtonDelegate {
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

extension NetworkVC: UISearchResultsUpdating {
    // Mark: -SearchBar
    func updateSearchResultsForSearchController(searchController: UISearchController){
        if (searchController.searchBar.text?.characters.count > 2) {
            Tapglue.searchUsersWithTerm(searchController.searchBar.text) { (users: [AnyObject]!, error: NSError!) -> Void in
                if users != nil && error == nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.users.removeAll(keepCapacity: false)
                        self.users = users as! [TGUser]
                        
                        self.reloadTableViewWithAnimation()
                    })
                } else if error != nil{
                    print("\nError searchUsersWithTerm: \(error)")
                }
            }
        } else {
            users.removeAll(keepCapacity: false)
            self.friendsTableView.reloadData()
        }
        
        if !searchController.active {
            users.removeAll(keepCapacity: false)
            self.friendsTableView.reloadData()
        }
    }
}
