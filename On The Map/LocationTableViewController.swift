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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let object = UIApplication.sharedApplication().delegate
        self.appDelegate = object as! AppDelegate
        
        ParseClient.getStudentLocations() {result, error in
            self.studentLocations = result as? [StudentLocation]
            self.tableView.reloadData()
        }
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