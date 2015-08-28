//
//  AddLocationViewController.swift
//  On The Map
//
//  Created by Greg Palen on 8/18/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class AddLocationViewController: UIViewController, UITextFieldDelegate {
	
	var location: CLLocation?
	var linkController: GetLinkViewController?
	
	@IBOutlet weak var locationTV: UITextField!
	
	@IBOutlet weak var findLocation: UIButton!
	
	override func viewDidLoad() {
		locationTV.delegate = self
		findLocation.enabled = false;
		findLocation.setTitle("Enter Location", forState: UIControlState.Disabled)
		
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.subscribeToTextChangeNotifications()
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		self.unsubscribeToTextChangeNotifications()
	}
	func subscribeToTextChangeNotifications() {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFindButtonState", name: UITextFieldTextDidChangeNotification, object: nil)
	}
	
	func unsubscribeToTextChangeNotifications() {
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: nil)
	}
	
	@IBAction func doCancel(sender: AnyObject) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	@IBAction func findLocation(sender: AnyObject) {
		getLocation()
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true;
	}
	
	func updateFindButtonState() {
		println("change")
		if locationTV.text.isEmpty {
			findLocation!.enabled = false
		} else {
			findLocation!.enabled = true
		}
	}
	
	func getLocation() {
		var locations = CLGeocoder()
		locations.geocodeAddressString(locationTV.text, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) in
			if error != nil {
				dispatch_async(dispatch_get_main_queue(), { () in
					self.showAlert("Problem Finding Location", message: "The location you entered cannot be converted to a GPS location. Please check the location you entered and try again.")
				})
			} else if placemarks.count > 0 {
				let placemark = placemarks[0] as! CLPlacemark
				self.location = placemark.location
				dispatch_async(dispatch_get_main_queue(), { () in
					self.showLinkController()
				})
			}
		})
	}
	
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "GetLink" {
			linkController = segue.destinationViewController as? GetLinkViewController
			linkController!.userLocation = location
			linkController!.mapString = locationTV.text
			linkController!.previousController = self
		}
	}
	
	func showLinkController() {
		self.performSegueWithIdentifier("GetLink", sender: self)
	}
	
}