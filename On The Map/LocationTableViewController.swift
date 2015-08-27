//
//  LocationTableViewController.swift
//  On The Map
//
//  Created by Greg Palen on 8/16/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//



import Foundation
import UIKit
class LocationTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate  {
    
    var studentLocations: [StudentLocation]? = nil
    var appDelegate: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var barButtonItems = [UIBarButtonItem]()
        barButtonItems.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "doRefresh"))
        barButtonItems.append(UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "doAddLocation"))
        self.navigationItem.rightBarButtonItems = barButtonItems
    }
    
    @IBAction func doLogout() {
        appDelegate.user = nil
        let loginController = storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        modalPresentationStyle = UIModalPresentationStyle.FullScreen
        presentViewController(loginController, animated: true, completion: nil)
    }
    
    func doRefresh() {
        ParseClient.getStudentLocations() {result, error in
            if error == nil {
                self.studentLocations = result
                dispatch_async(dispatch_get_main_queue(), { () in
                    self.tableView.reloadData()
                    self.view.makeToast(message: "Locations have been updated", duration: HRToastDefaultDuration, position: HRToastPositionCenter)
                })
            } else {
                if error?.domain == NSURLErrorDomain {
                    self.showAlert("Network Error", message: "A network error has occurred: \(error!.localizedFailureReason)")
                } else {
                    self.showAlert("Server Error",
                        message: "The server has returned an error: \n" +
                        "Response Code: \(error!.code). \((error!.userInfo?[NSURLErrorKey]) as! String)")
                }
            }
        }
    }
    
    func doAddLocation() {
        println("add location")
        let detailController = storyboard!.instantiateViewControllerWithIdentifier("AddLocationViewController") as! AddLocationViewController
        modalPresentationStyle = UIModalPresentationStyle.FullScreen
        modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        presentViewController(detailController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let object = UIApplication.sharedApplication().delegate
        self.appDelegate = object as! AppDelegate
        doRefresh()
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.studentLocations == nil) {return 0}
        return self.studentLocations!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationTableViewCell") as! LocationTableViewCell
        let location = studentLocations![indexPath.row]
        
        // Set the name and image
        cell.studentName!.text = location.firstName! + " " + location.lastName!
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let studentURL = studentLocations![indexPath.row].mediaURL {
            UIApplication.sharedApplication().openURL(NSURL(string: studentURL)!)
        }
    }
}