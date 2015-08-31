//
//  GetLinkViewController.swift
//  On The Map
//
//  Created by Greg Palen on 8/19/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//


//	The second of two views that are used to gather the data needed to create a new post by the user to the Udacity
//	Parse database.

//  Note that UIViewController is extended by UIViewControllerExtension.swift which contains
//  the code to raise an AlertView by any of the view controllers in this application.

import Foundation
import CoreLocation
import UIKit
import MapKit

class GetLinkViewController: UIViewController, MKMapViewDelegate  {

	var userLocation: CLLocation?	// the coordinates that resulted from the geocoding. This will be set by the prior controller
	var mapString: String?			// the location that the user entered into the location field. This text was used to forward-geocode
	var mediaURL: String?			// This will contain the URL that the user enters on this screen
	var student: UdacityUser?		// A reference to an UdacityUser, useful for obtaining the name and user ID of the user
	var previousController: AddLocationViewController?	// A reference to the controller that invoked this controller to make cancelling easier
	
	// An outlet to the field where the user enters the URL they want included in the posting
	@IBOutlet weak var linkTF: UITextField!
	
	// An outlet to the MapVIew itself. Used by the various delegate functions below.
	@IBOutlet weak var mapView: MKMapView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let locationAnnotation = MKPointAnnotation()
		locationAnnotation.coordinate = userLocation!.coordinate
		mapView.addAnnotation(locationAnnotation)
		mapView.centerCoordinate = userLocation!.coordinate
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		// get a reference to the app delegate in order to get to the currently logged-in user
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		// retrieve the user from the delegate
		student = AppConfiguration.sharedConfiguration.user!
	}
	
	// This function is triggered when the user taps the Cancel button in the upper-right corner.
	@IBAction func doCancel() {
		// In order to dismiss two view controllers that were both presented modally and to do that in a visually smooth way,
		// it's necessary to pass a completionHandler to this ViewController in the call to dismiss itself so that when it's
		// done dismissing itself, it then dismisses the prior controller as well. This sequence looks the most natural visually.
		self.dismissViewControllerAnimated(false, completion: {() in
			self.previousController!.dismissViewControllerAnimated(true, completion: nil)
		})
	}

	// Function that is triggered when the user taps the Submit button at the bottom of the screen to submit a new posting
	@IBAction func doSubmit(sender: AnyObject) {
		// Get the URL the user entered into the text field
		mediaURL = linkTF.text
		if isValid(mediaURL) {	// do some basic validation of the URL the user entered to make sure it at least looks like a URL
			// if valid, initiate a request via the ParseClient to post the location, passing the entered data as parameters
			ParseClient.doPostStudentLocation(userLocation, mapString: mapString, mediaURL: mediaURL, student: student) {(result, error) in
				if error == nil {
					// if the call succeeds with no error, show a success message. When the user acknowledges that success message,
					// this view and the prior (1st) view will both be dismissed and the user will be back at the tabbed view of
					// all the locations. That particular view will automatically refresh which should then cause the newly posted
					// location to appear.
					dispatch_async(dispatch_get_main_queue(), { () in
						self.showAlert("Success!", message: "Your post was added successfully") { () in
							self.doCancel()
						}
					})
					
				} else {
					// An error occurred, so show an appropriate message. After the user acks the message, they will remain
					// on this screen so they can try to submit again.
					dispatch_async(dispatch_get_main_queue(), { () in
						self.showAlert("ERROR!", message: "An error occurred when trying to post: \(error!.description)")
					})
				}
			}
		} else {
			// The URL the user entered didn't appear to be valid, so show a message and give them a chance to correct it.
			showAlert("URL Invalid", message: "The URL you entered is invalid or blank. Please check the URL and try again.")
		}
	}
	
	// Helper function that does some basic validation of the string entered against a relatively simplistic regular expression
	// Note that this regex is by no means exhaustive - it is simply looking for some basic attributes.
	// A return that is NON-NIL means that the URL is valid; if the return is NIL, the URL appears to be invalid.
	func isValid (url: String!) -> Bool {
		// This regex will allow the user to optionally enter the http(s):// at the front of the URL. It will validate
		// that if that optional component is entered, it's spelled and entered correctly (two trailing slashes).
		// It also validates that the user entered at least a valid domain like apple.com. Any host preceding the domain
		// is accepted and any trailing characters of any kind are accepted (this is where the regex is less than optimal)
		let regex = "^(https?://)?([a-zA-Z0-9-]+[.])*([a-zA-Z0-9-])+[.][a-zA-Z]{2,3}(/.*)?$"
		// for rangeOfString to return something other than nil, the text must match the above regular expression, meaning
		// it appears to be a valid URL.
		return url.rangeOfString(regex, options: NSStringCompareOptions.RegularExpressionSearch) != nil
	}
	
	// MapView delegate method that allows an annotation view to be instantiated and displayed
	func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
		
		let reuseId = "pin"
		
		var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
		
		if pinView == nil {
			pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
			pinView!.canShowCallout = false
			pinView!.pinColor = .Red
		}
		else {
			pinView!.annotation = annotation
		}
		
		return pinView
	}
	
	
	// This delegate method is implemented to respond to taps. It simply returns, which functionally disables any
	// tap response.
	func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		
		if control == annotationView.rightCalloutAccessoryView {
			return
		}
	}
}