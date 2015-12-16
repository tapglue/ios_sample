//
//  NewsVC.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 16/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit

class NewsVC: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    let url = "https://www.tapglue.com/blog/"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadTapglueBlogPage()
    }
    
    @IBAction func goHome(sender: UIBarButtonItem) {
        loadTapglueBlogPage()
    }
    
    @IBAction func doRefresh(sender: UIBarButtonItem) {
        webView.reload()
    }
    @IBAction func goBack(sender: UIBarButtonItem) {
        webView.goBack()
    }
    @IBAction func goForward(sender: UIBarButtonItem) {
        webView.goForward()
    }
    
    func loadTapglueBlogPage(){
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)
        webView.loadRequest(request)
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
