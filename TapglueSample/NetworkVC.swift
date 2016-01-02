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
    
    var facebookID: String!
    var twitterID: String!
    
    // Array of FacebookFriends
    var friendsFromFacebook: [AnyObject]? = []
    
    let facebookLogInButton = FBSDKLoginButton()
    
    var twitterLogInButton = TWTRLogInButton()
    
    var checkingForPendingConnections = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            self.friendsTableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        // Reload the TableView
        self.friendsTableView.reloadData()
        
        // hide button
        networkButton.hidden = true
        
        configureFacebook()
        
        twitterLogInButton = TWTRLogInButton(logInCompletion: { session, error in
            if (session != nil) {
                print("signed in as \(session!.userName)")
                self.twitterLogin()
                
            } else {
                print("error: \(error!.localizedDescription)")
            }
        })
        
        checkForPendingConnections()
        
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
                clearUsersArrayAndReloadTableView()
                checkForPendingConnections()
                friendsTableView.tableHeaderView = resultSearchController.searchBar
                self.resultSearchController.active = true
            
            case 1:
                outsidePendingSegment()
                clearUsersArrayAndReloadTableView()
                contactsSegmentWasPicked()
            
            case 2:
                outsidePendingSegment()
                clearUsersArrayAndReloadTableView()
                facebookSegmentWasPicked()
            
            case 3:
                outsidePendingSegment()
                clearUsersArrayAndReloadTableView()
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
                print("\nSuccessful: \(users)")
                self.users.removeAll(keepCapacity: false)
                self.users = users as! [TGUser]
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.networkButton.hidden = true
                    self.friendsTableView.reloadData()
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
                    for item in contact.emailAddresses {
                        self.contactEmails.append(String(item.value))
                    }
                }
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
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.facebookLogInButton.hidden = true
                                self.friendsTableView.reloadData()
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
    
    var countTwitter = 0
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
                                    
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        self.twitterLogInButton.hidden = true
                                        self.friendsTableView.reloadData()
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
        self.friendsTableView.reloadData()
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
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.friendsTableView.reloadData()
                    
                })
            }
        }
    }
    
    func outsidePendingSegment() {
        friendsTableView.tableHeaderView = nil
        self.resultSearchController.active = false
        
        self.checkingForPendingConnections = false
    }
}

extension NetworkVC: UITableViewDataSource {
    // Mark: -TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NetworkUserTableViewCell
        
        let user = self.users[indexPath.row]
        
        cell.userImageView.image = nil
        
        if checkingForPendingConnections {
            cell.checkingForPendingConnections = true
            cell.configureCellWithUserWithPendingConnection(user)
        } else{
            cell.configureCellWithUserToFriendOrFollow(user)
        }
        
        return cell
        
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
                //            let strFirstName: String = (result.objectForKey("first_name") as? String)!
                //            let strLastName: String = (result.objectForKey("last_name") as? String)!
                //            let strPictureURL: String = (result.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as? String)!
                //            self.lblName.text = "Welcome, \(strFirstName) \(strLastName)"
                //            self.ivUserProfileImage.image = UIImage(data: NSData(contentsOfURL: NSURL(string: strPictureURL)!)!)
                
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
                        self.friendsTableView.reloadData()
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
