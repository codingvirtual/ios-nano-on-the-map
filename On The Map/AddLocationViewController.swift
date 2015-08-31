//
//  AddLocationViewController.swift
//  On The Map
//
//  Created by Greg Palen on 8/18/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//

//	Controller that manages the first of two views that gather necessary data to allow the user
//	to post a location and URL to the Udacity Parse database.

//  Note that UIViewController is extended by UIViewControllerExtension.swift which contains
//  the code to raise an AlertView by any of the view controllers in this application.

import Foundation
import UIKit
import CoreLocation

class AddLocationViewController: UIViewController, UITextFieldDelegate {
	
	var location: CLLocation?
	// A reference to the 2nd of the two views that are needed to gather data for the user's post
	var linkController: GetLinkViewController?
	
	// An outlet for the activity indicator (spinning thing)
	@IBOutlet weak var activityView: UIActivityIndicatorView!
	
	// An outlet to the text field where the user types in the location they want to use for the post
	// The text property of this object will be forward-geocoded to a map location
	@IBOutlet weak var locationTV: UITextField!
	
	// An outlet to the Find On The Map button that the user clicks after entering their location
	@IBOutlet weak var findLocation: UIButton!
	
	// Override default functionality in order to set the delegate for the text field to this class
	// and to disable the Find button (it will be enabled after the user types something into the location field)
	override func viewDidLoad() {
		locationTV.delegate = self
		findLocation.enabled = false;
		findLocation.setTitle("Enter Location", forState: UIControlState.Disabled)
	}
	
	// Override the default functionality to allow us to be notified of text field notifications which is
	// required for us to manage the state of the Find button
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.subscribeToTextChangeNotifications()
	}
	
	// Override required to resign notifications related to the text field
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		self.unsubscribeToTextChangeNotifications()
	}
	
	// Helper function that sets up notifications when the location text field changes. In this case, we will call the
	// updateFindButtonState method to handle the state of the button
	func subscribeToTextChangeNotifications() {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFindButtonState", name: UITextFieldTextDidChangeNotification, object: nil)
	}
	
	// Helper function that tears down notifications when the location text field changes.
	func unsubscribeToTextChangeNotifications() {
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: nil)
	}
	
	// Function that is triggered when the user taps the Cancel button in the upper-right corner to cancel the process
	// of adding a new post. Dismisses this view controller which has the effect of returning the user to the tabbed view
	// they were in when they hit the Add Location button.
	@IBAction func doCancel(sender: AnyObject) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	// Function that is triggered when the user taps the "Find on the Map" button at the bottom of the screen.
	@IBAction func findLocation(sender: AnyObject) {
		getLocation()
	}
	
	// TextField delegate function that allows us to resign first responder status when editing of the field is done.
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true;
	}
	
	// Helper function that sets the state of the Find on the Map button. If the user has entered ANY text into the
	// location field, the button will be enabled, allowing them to try to find that location using forward-geocoding.
	func updateFindButtonState() {
		if locationTV.text.isEmpty {
			findLocation!.enabled = false
		} else {
			findLocation!.enabled = true
		}
	}
	
	// Function that searches for the lcoation the user entered in the location text field
	func getLocation() {
		// Show the "activity spinner" and start it spinning while the geocoding progresses
		activityView.startAnimating()
		// Create a geocoder object
		var locations = CLGeocoder()
		// Attempt to geocode the string the user entered into the text box, passing a completion handler in to deal
		// with the success or failure
		locations.geocodeAddressString(locationTV.text, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) in
			// First, stop the activity spinner. Note in Storyboard that it is set to auto-hide when stopped, so this
			// will also cause it to disappear.
			dispatch_async(dispatch_get_main_queue(), { () in
				self.activityView.stopAnimating()
			})
			// Now process the outcome
			if error != nil {
				// if there was an error, show an appropriate error message
				dispatch_async(dispatch_get_main_queue(), { () in
					self.showAlert("Problem Finding Location", message: "The location you entered cannot be converted to a GPS location. Please check the location you entered and try again.")
				})
			} else if placemarks.count > 0 {
				// there was no error and the result contained at least one record. We will make the large assumption that the first
				// response is the right one. It would probably be better to check the count and if more than one, throw a picker up
				// that lets them choose the right one.
				let placemark = placemarks[0] as! CLPlacemark
				self.location = placemark.location		// update the internal property of this class with the geocoded location
				dispatch_async(dispatch_get_main_queue(), { () in
					// since the location geocode succeeded, now we present the 2nd screen that collects the URL the user wants in the post
					self.showLinkController()
				})
			}
		})
	}
	
	// Override to set up the reference to the 2nd screen of data collection and prepare it with the data from the geocoding
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "GetLink" {
			linkController = segue.destinationViewController as? GetLinkViewController
			// set the location in the next controller as well as passing along the text the user entered to get that location to geocode
			linkController!.userLocation = location
			linkController!.mapString = locationTV.text
			// Pass a reference to this controller to the next one. This will allow that controller to more seamlessly "unwind" back to
			// the tabbed location view if they hit Cancel on the next screen
			linkController!.previousController = self
		}
	}
	
	// Helper function that simply initiates the segue to the 2nd screen
	func showLinkController() {
		self.performSegueWithIdentifier("GetLink", sender: self)
	}
	
}