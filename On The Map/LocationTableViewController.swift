//
//  LocationTableViewController.swift
//  On The Map
//
//  Created by Greg Palen on 8/16/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//

// This controller is responsible for handling the student posting locations when presented
// as a Table using the TableView. It acts not only as a view controller, but also as
// the table data source delegate and the TableView delegate as well.

// Note that UIViewController is extended by UIViewControllerExtension.swift which contains
// the code to raise an AlertView by any of the view controllers in this application.

import Foundation
import UIKit
class LocationTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate  {
	
	// List of student posting locations - the ultimate data source for the table
	// The list gets populated via an HTTP call to the Parse API that queries the Udacity database.
	var studentLocations: [StudentLocation]? = nil
	// A reference the app delegate which stores the UdacityUser that is logged into the app
	let appDelegate: AppDelegate! = UIApplication.sharedApplication().delegate as! AppDelegate
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Set up a pair of buttons to occupy the right bar button location. The first button is the Refresh button (with the refresh icon)
		// which causes the student locations data to be queried again from the Parse API and then the list updated. The 2nd button, which is
		// actually the left-most of the two buttons and is signified by a Map Point icon, allows the user to add a location of their choosing to the database.
		var barButtonItems = [UIBarButtonItem]()
		barButtonItems.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "doRefresh"))
		barButtonItems.append(UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "doAddLocation"))
		self.navigationItem.rightBarButtonItems = barButtonItems
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		// Refresh the table view. Even though the super class will do this anyway, it's included here to also trigger
		// the appearance of a notification to the user that the locations have in fact been udpated, which the default
		// TableViewController would not do.
		doRefresh()
	}
	
	
	// An action that is triggered when the user clicks the Logout button. It resets the logged-in user (which has the effect of logging them
	// out in this app) and then returns to the login screen.
	@IBAction func doLogout() {
		AppConfiguration.sharedConfiguration.user = nil	// reset the currently logged-in user
		// Get a reference to the login controller and then present it so a new login attempt can begin
		let loginController = storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
		modalPresentationStyle = UIModalPresentationStyle.FullScreen
		presentViewController(loginController, animated: true, completion: nil)
	}
	
	// Function that is called when the user taps the Refresh icon in the upper-right corner of the screen AND
	// when the view initially appears.
	// The function initiates a call to the Parse API via the ParseClient class.
	// If the call is successful, it sets the results as the studentLocations property of the controller and
	// tells the table to reload using this new data, then displays a small "toast" (sorry for the Android reference)
	// notifying the user that the locations have been updated.
	// If the call fails, an AlertView is displayed with information about the error.
	func doRefresh() {
		ParseClient.getStudentLocations() {result, error in
			if error == nil {
				// The request was successful, so update the list of locations in storage
				// then display a "toast" (sorry for the Android reference) to notify the user that the update was successful
				self.studentLocations = result
				dispatch_async(dispatch_get_main_queue(), { () in
					self.tableView.reloadData()
					self.view.makeToast(message: "Locations have been updated", duration: HRToastDefaultDuration, position: HRToastPositionCenter)
				})
			} else {
				// There was an error with the request. Determine what type of error and display and appropriate message to the user.
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
	
	// Funtion that is triggered when the user taps the Map Point icon in the upper-right corner signifying they want to add a new location
	// to the database.
	func doAddLocation() {
		// Get a reference to the controller that begins the process of collecting the user's location post info and then present it modally
		let detailController = storyboard!.instantiateViewControllerWithIdentifier("AddLocationViewController") as! AddLocationViewController
		modalPresentationStyle = UIModalPresentationStyle.FullScreen
		modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
		presentViewController(detailController, animated: true, completion: nil)
	}

	
	// Required override of the DataSource delegate protocol that returns the number of rows (elements in the studentLocations array)
	// that are in the data set.
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if (self.studentLocations == nil) {return 0}
		return self.studentLocations!.count
	}
	
	// Required override of the DataSource delegate protocol that returns a specific cell of data from the datasource
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("LocationTableViewCell") as! UITableViewCell
		let location = studentLocations![indexPath.row]
		// Set the first and last name of the student as the cell text
		cell.textLabel!.text = location.firstName! + " " + location.lastName!
		
		return cell
	}
	
	// Required override of the TableView protocol that provides an action when a row of the data in the table is selected.
	// In this case, it launches Safari to open the URL that the student posted to the database.
	// NOTE: additional data validation could be performed to ensure that the data is in fact a valid URL.
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if let studentURL = studentLocations![indexPath.row].mediaURL {
			UIApplication.sharedApplication().openURL(NSURL(string: studentURL)!)
		}
	}
}