//
//  GetSocialIDsViewController.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 22/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue
import FBSDKLoginKit
import TwitterKit

class GetSocialIDsViewController: UIViewController, FBSDKLoginButtonDelegate {

//    var client = TWTRAPIClient()
    
    @IBOutlet var btnTwitter: TWTRLogInButton!
    @IBOutlet var btnFacebook: FBSDKLoginButton!
    @IBOutlet var ivUserProfileImage: UIImageView!
    
    @IBOutlet var lblName: UILabel!
    
    // Array of friends to add to your friends
    var friendThisPeople: [AnyObject]? = []
    var friendsFromTwitter: [AnyObject]? = []
    
    // Test // Friends: The right Friends Count need to be implemented
    var friends: Int = 0
    
    var facebookID: String!
    
    var twitterID: String!
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        let logInButton = TWTRLogInButton(logInCompletion: { session, error in
//            if (session != nil) {
//                print("signed in as \(session!.userName)");
//            } else {
//                print("error: \(error!.localizedDescription)");
//            }
//        })
//        logInButton.center = self.view.center
//        self.view.addSubview(logInButton)
        
        btnFacebook.readPermissions = ["public_profile", "email", "user_friends"];
        btnFacebook.delegate = self
    }
    
    @IBAction func getTwitterFriendsButtonPressed(sender: UIButton) {
        getTwitterFriends(-1)
    }
    
    @IBAction func getFacebookFriendsButtonPressed(sender: UIButton) {
        returnUserFriendsData()
    }
    
    @IBAction func twitterButtonPressed(sender: TWTRLogInButton) {
        Twitter.sharedInstance().logInWithCompletion { (session: TWTRSession?, error: NSError?) -> Void in
            if (session != nil) {
                print("signed in as: \(session!.userName)")
                print("signed in as: \(session!.userID)")
                print("signed in as: \(session!)")
                self.twitterID = session!.userID
//                self.client = TWTRAPIClient(userID: session!.userID)
                    // make requests with client
//                    print(self.client.userID)
                
                // add tapglue social id from facebook
                let currentUser = TGUser.currentUser()
                currentUser.setSocialId(self.twitterID, forKey: "twitter")
                currentUser.saveWithCompletionBlock({ (success: Bool, error: NSError!) -> Void in
                    print(success)
                })
                
                self.getTwitterFriends(-1)
                
            } else {
                print("error: \(error!.localizedDescription)")
            }
        }
    }
    

    
    func getTwitterFriends(nextCursor: Int){
        var clientError:NSError?
        let params: Dictionary = Dictionary<String, String>()
        
        var cursorNext: Int!
        
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
                    var jsonError: NSError?
                    let json: AnyObject? = try!
                    NSJSONSerialization.JSONObjectWithData(data!,
                        options: .MutableContainers)
                    
                    // check for json data
                    if (json != nil) {
//                        print("response = \(json)")
//                        print(json?.valueForKey("ids"))
                        
                        
                        let resultdict = json as! NSDictionary
                        //                print("Result Dict: \(resultdict)")
                        
                        cursorNext = resultdict.objectForKey("next_cursor") as! Int
                        
                        print("NextCursor: \(cursorNext)")
                        
                        let data: NSArray = resultdict.objectForKey("ids") as! NSArray
                        //                print("Result Data: \(data)")
                        print(data)
                        for id in data {
                            self.friendsFromTwitter?.append(id)
                        }
                        
                        print(self.friendsFromTwitter!.count)
                        // add friends that are found
//                        Tapglue.searchUsersOnSocialPlatform("twitter", withSocialUsersIds: self.friendsFromTwitter, andCompletionBlock: { (users: [AnyObject]!, error: NSError!) -> Void in
//                            if (users != nil) {
//                                print("users: \(users)")
//                            } else {
//                                print("error: \(error)")
//                            }
//                        })
                        
                        if nextCursor != 0 {
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
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, last_name, picture.type(large), id"]).startWithCompletionHandler { (connection, result, error) -> Void in
            let strFirstName: String = (result.objectForKey("first_name") as? String)!
            let strLastName: String = (result.objectForKey("last_name") as? String)!
            let strPictureURL: String = (result.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as? String)!
            self.lblName.text = "Welcome, \(strFirstName) \(strLastName)"
            self.ivUserProfileImage.image = UIImage(data: NSData(contentsOfURL: NSURL(string: strPictureURL)!)!)
            
            self.facebookID = (result.objectForKey("id") as? String)!
            
                // Add facebook social id to TGUser.currentUser
                let currentUser = TGUser.currentUser()
                currentUser.setSocialId(self.facebookID, forKey: "facebook")
                currentUser.saveWithCompletionBlock({ (success: Bool, error: NSError!) -> Void in
                    print(success)
                })
            }
        returnUserFriendsData()
    }
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
        ivUserProfileImage.image = nil
        lblName.text = ""
    }
    
    // start returning facebook friends to tapglue
    func returnUserFriendsData()
    {
        
        if (FBSDKAccessToken.currentAccessToken() != nil){
            let friendsRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/friends?fields=id", parameters: nil)
            friendsRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                if ((error) != nil)
                {
                    // error
                    print("Error: \(error)")
                }
                else
                {
                    let resultdict = result as! NSDictionary
    //                print("Result Dict: \(resultdict)")
                    
                    let data: NSArray = resultdict.objectForKey("data") as! NSArray
    //                print("Result Data: \(data)")
                    for i in 0 ..< data.count
                    {
                        let valueDict: NSDictionary = data[i] as! NSDictionary
                        let id = valueDict.objectForKey("id") as! String
                        print("Friend id value is \(id)")
                        
                        // save facebook friend ids inside AnyObject array
                        self.friendThisPeople?.append(id)
                        self.friends++
                    }
                    // add tapglue social id from facebook

                    // add friends that are found
                    Tapglue.searchUsersOnSocialPlatform("facebook", withSocialUsersIds: self.friendThisPeople, andCompletionBlock: { (users: [AnyObject]!, error: NSError!) -> Void in
                        print(users)
                    })
                }
            })
        }
    }
    

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
