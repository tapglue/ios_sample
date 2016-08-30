//
//  ConnectionVC.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 21/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue
import Contacts
import FBSDKLoginKit
import FBSDKCoreKit

class ConnectionVC: UIViewController, UITableViewDelegate {
    
    let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var users: [User] = []
    var fromUsers: [User] = []
    var toUsers: [User] = []
    
    var resultSearchController: UISearchController!
    
    let contactStore = CNContactStore()
    var contactEmails: [String] = []
    var contacts: [[String:String]] = []
    
    var searchingForUser = false
    
    var sections = ["Find Friends", "Pending Requests"]
    var networks = ["Contacts", "Facebook"]
    let networkImages = ["AddressBookFilled", "FacebookFilled"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.backgroundColor = .whiteColor()
            
            self.friendsTableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        // Setup searchBar
        resultSearchController.searchResultsUpdater = self
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.dimsBackgroundDuringPresentation = false
        resultSearchController.searchBar.sizeToFit()
        resultSearchController.searchBar.searchBarStyle = .Minimal
        resultSearchController.searchBar.placeholder = "search"
        self.friendsTableView.tableHeaderView = resultSearchController.searchBar
    }
    
    override func viewWillAppear(animated: Bool) {
        clearUsersArrayAndReloadTableView()
        checkForPendingConnections()
        
        reloadTableViewWithAnimation()
        
        self.resultSearchController.searchBar.hidden = false
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.resultSearchController.searchBar.hidden = true
        self.resultSearchController.active = false
    }
    
    @IBAction func conctactsBtnPressed(sender: UIButton) {
        let storyboard = UIStoryboard(name: "FindUsers", bundle: nil)
        let fuVC = storyboard.instantiateViewControllerWithIdentifier("FindUsersViewController")
            as! FindUsersVC
        
        fuVC.currentSelectedNetwork = "Contacts"
        
        self.navigationController!.pushViewController(fuVC, animated: true)
    }
    
    @IBAction func facebookBtnPressed(sender: UIButton) {
        
    }
    
    func clearUsersArrayAndReloadTableView(){
        self.fromUsers.removeAll(keepCapacity: false)
        self.toUsers.removeAll(keepCapacity: false)
        self.users.removeAll(keepCapacity: false)
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.friendsTableView.reloadData()
        })
    }
    
    func checkForPendingConnections(){
        // Retrieve pending connection requests
        appDel.rxTapglue.retrievePendingConnections().subscribe { (event) in
            switch event {
            case .Next(let connections):
                print("Next")
                
                for inc in connections.incoming! {
                    self.fromUsers.append(inc.userFrom!)
                }
                
                for out in connections.outgoing! {
                    self.toUsers.append(out.userTo!)
                }
                
                //                print("From user: \(self.fromUsers)")
                //                print("To user: \(self.toUsers)")
                
                // As an example we are just showing inbound friends request
                self.users = self.fromUsers
                
                self.users.sortInPlace({ (contact1, contact2) -> Bool in
                    return contact1.username < contact2.username
                })
                
                self.reloadTableViewWithAnimation()
                
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Completed")
                
            }
            }.addDisposableTo(self.appDel.disposeBag)
    }
}

extension ConnectionVC: UITableViewDataSource {
    // Mark: -TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ConnectionUserTableViewCell
        
        if searchingForUser {
            cell.searchingForUser = true
            cell.configureCellWithUserToFriendOrFollow(self.users[indexPath.row])
        } else {
            cell.delegate = self
            cell.selectionStyle = .None
            cell.userNameLabel.text = self.users[indexPath.row].firstName
            let user = self.users[indexPath.row]
            cell.configureCellWithUserWithPendingConnection(user)
        }
        
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            let storyboard = UIStoryboard(name: "FindUsers", bundle: nil)
            let fuVC = storyboard.instantiateViewControllerWithIdentifier("FindUsersViewController")
                as! FindUsersVC
            
            fuVC.currentSelectedNetwork = networks[indexPath.row]
            
            self.navigationController!.pushViewController(fuVC, animated: true)
        }
    }
    
    func reloadTableViewWithAnimation() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.transitionWithView(self.friendsTableView,
                duration:0.3,
                options:.TransitionCrossDissolve,
                animations:
                { () -> Void in
                    self.friendsTableView.reloadData()
                },
                completion: nil);
        })
    }
}

extension ConnectionVC: UISearchResultsUpdating {
    // Mark: - SearchController
    func updateSearchResultsForSearchController(searchController: UISearchController){
        if (searchController.searchBar.text?.characters.count > 2) {
            // Search for User
            appDel.rxTapglue.searchUsersForSearchTerm(searchController.searchBar.text!).subscribe({ (event) in
                switch event {
                case .Next(let usr):
                    print("Next")
                    self.searchingForUser = true
                    
                    self.users.removeAll(keepCapacity: false)
                    self.users = usr
                    
                    self.reloadTableViewWithAnimation()
                    
                case .Error(let error):
                    self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                case .Completed:
                    print("Completed")
                }
                
            }).addDisposableTo(self.appDel.disposeBag)
            
        } else {
            // Clear tableView as long a user was not found
            searchingForUser = true
            users.removeAll(keepCapacity: false)
            self.friendsTableView.reloadData()
        }
        
        if !searchController.active {
            clearUsersArrayAndReloadTableView()
            checkForPendingConnections()
            searchingForUser = false
        }
    }
}

extension ConnectionVC: PendingConnectionsDelegate {
    // Mark: - Custom delegate to update data, if cell recieves like button or share button pressed
    func updatePendingConnections() {
        clearUserArrays()
        
        // Retrieve pending connection requests
        appDel.rxTapglue.retrievePendingConnections().subscribe { (event) in
            switch event {
            case .Next(let connections):
                print("Next")
                
                for inc in connections.incoming! {
                    print("incomging user: \(inc.userFrom)")
                    self.fromUsers.append(inc.userFrom!)
                }
                
                for out in connections.outgoing! {
                    self.toUsers.append(out.userTo!)
                }
                
                print("From user: \(self.fromUsers)")
                print("To user: \(self.toUsers)")
                
                // As an example we are just showing inbound friends request
                self.users = self.fromUsers
                
                self.users.sortInPlace({ (contact1, contact2) -> Bool in
                    return contact1.username < contact2.username
                })
                
                
                self.reloadTableViewWithAnimation()
                
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Completed")
                
            }
        }.addDisposableTo(self.appDel.disposeBag)
    }
    
    func clearUserArrays() {
        self.users.removeAll(keepCapacity: false)
        self.fromUsers.removeAll(keepCapacity: false)
        self.toUsers.removeAll(keepCapacity: false)
    }
}
