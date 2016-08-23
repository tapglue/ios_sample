//
//  FilteredTagsVC.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 23/08/16.
//  Copyright © 2016 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue
import WSTagsField

class FilteredTagsVC: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var filteredTableView: UITableView!
    
    var posts: [Post] = []
    var tags: [String] = []
    
    let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    var resultSearchController: UISearchController!
    
    let tagsField = WSTagsField()

    override func viewDidLoad() {
        super.viewDidLoad()

        addWSTagsField()
        
        // Events
        tagsField.onDidAddTag = { _ in
            self.filterPostByTags()
        }
        
        tagsField.onDidRemoveTag = { _ in
            self.filterPostByTags()
        }
    }
    
    func filterPostByTags() {
        var tempTags: [String] = []
        
        for wsTag in self.tagsField.tags {
            print(wsTag.text)
            tempTags.append(wsTag.text)
        }
        
        self.appDel.rxTapglue.filterPostsByTags(tempTags).subscribe { (event) in
            switch event {
            case .Next(let posts):
                print("Next")
                self.posts.removeAll(keepCapacity: false)
                self.posts = posts
                
                print(posts.count)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.filteredTableView.reloadData()
                })
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Do the action")
            }
            }.addDisposableTo(self.appDel.disposeBag)
    }
    
    func addWSTagsField() {
        tagsField.placeholder = "Search for tags"
        tagsField.font = UIFont(name:"HelveticaNeue-Light", size: 14.0)
        tagsField.tintColor = UIColor(red:0.18, green:0.28, blue:0.3, alpha:1.0)
        tagsField.textColor = .whiteColor()
        tagsField.selectedColor = .lightGrayColor()
        tagsField.selectedTextColor = .whiteColor()
        tagsField.spaceBetweenTags = 4.0
        tagsField.padding.left = 15
        tagsField.backgroundColor = .whiteColor()
        tagsField.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        
        tagsField.addTags(tags)
        
        self.filteredTableView.tableHeaderView = tagsField
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

extension FilteredTagsVC: UITableViewDataSource {
    // Mark: - TableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FilteredTagsTableViewCell
        
        cell.configureCellWithPost(self.posts[indexPath.row])
        
        // Listen custom delegate
        cell.delegate = self
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "PostDetail", bundle: nil)
        let pdVC =
            storyboard.instantiateViewControllerWithIdentifier("PostDetailViewController")
                as! PostDetailVC
        
        pdVC.post = posts[indexPath.row]
        
        pdVC.usr = posts[indexPath.row].user
        
        self.navigationController?.pushViewController(pdVC, animated: true)
    }
}

extension FilteredTagsVC: FilteredCustomCellDataUpdater {
    // Mark: - Custom delegate to update data, if cell recieves like button or share button pressed
    func updateFilteredTableViewData() {
        // Load All Posts from your connections
        filterPostByTags()
    }
    
    func showFilteredShareOptions(post: Post) {
        let postAttachment = post.attachments
        let postText = postAttachment![0].contents!["en"]
        let postActivityItem = "@" + (post.user?.username)! + " posted: \(postText!)! Check it out on TapglueSample."
        
        let activityViewController: UIActivityViewController = UIActivityViewController(
            activityItems: [postActivityItem], applicationActivities: nil)
        
        activityViewController.excludedActivityTypes = [
            UIActivityTypePostToWeibo,
            UIActivityTypePrint,
            UIActivityTypeAssignToContact,
            UIActivityTypeSaveToCameraRoll,
            UIActivityTypeAddToReadingList,
            UIActivityTypePostToFlickr,
            UIActivityTypePostToVimeo,
            UIActivityTypePostToTencentWeibo,
            UIActivityTypeMail
        ]
        
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
}