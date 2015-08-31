//
//  MapViewController.swift
//  On The Map
//
//  Created by Greg Palen on 8/18/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//

//	This class provides a Map View of the student locations with each location depicted as
//	a MapPoint on the map. Clicking on a map point will show an informational view that provides
//	the user's name and the URL they put in. CLicking this info view will open Safari to the
//	URL associated with that student post.

//  Note that UIViewController is extended by UIViewControllerExtension.swift which contains
//  the code to raise an AlertView by any of the view controllers in this application.

import Foundation
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
	
	// The map. See the setup in the Storyboard file. Note particularly that the view controller
	// is set up as the map view's delegate.
	@IBOutlet weak var mapView: MKMapView!
	
	// The "studentLocations" array is an array of dictionary objects that are downloaded from Parse
	var studentLocations: [StudentLocation]?
	// A reference to the app delegate that allows access to the user that is logged in
	let appDelegate: AppDelegate! = UIApplication.sharedApplication().delegate as! AppDelegate
	
	// Override default functionality to allow this controller to add two buttons to the right bar button in the
	// navigation bar.
	override func viewDidLoad() {
		super.viewDidLoad()
		var barButtonItems = [UIBarButtonItem]()
		// The right-most button is the refresh icon and when tapped, triggers the doRefresh method that fetches updated Parse records
		barButtonItems.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "doRefresh"))
		// The 2nd button from the right is a Map Point icon and allows the user to add a location to the Udacity Parse database
		barButtonItems.append(UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "doAddLocation"))
		self.navigationItem.rightBarButtonItems = barButtonItems
	}
	
	// Override the default functionality to allow a Parse API call to go and fetch student locations
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		doRefresh()
	}

	// Function that invokes a call to the ParseClient class to request the latest student posts.
	func doRefresh() {
		// If there are existing map annotations, clear them all out to prepare for the new load
		if mapView.annotations != nil { mapView.removeAnnotations(mapView.annotations) }
		// call the ParseClient to get the latest locations. Pass a completionHandler that allows the updating of this view
		// and an appropriate message of success or failure
		ParseClient.getStudentLocations() {result, error in
			if error == nil {
				// There was no error, so update the list of locations
				self.studentLocations = result
				// Dispatch a call to the UI thread to create the new annotations since the data has been updated, then
				// show a "toast" (sorry for the Android reference) notifying the user that the locations have been udpated
				dispatch_async(dispatch_get_main_queue(), { () in
					self.createAnnotations()
					self.view.makeToast(message: "Locations have been updated", duration: HRToastDefaultDuration, position: HRToastPositionCenter)
				})
			} else {
				// There was an error. Differentiate between the types of error it could be and display an apprpriate message.
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
	
	// Function that triggers the presentation of the first of two views that allow the user to enter and post a new location to the
	// Parse database. This view is presented modally
	func doAddLocation() {
		let detailController = storyboard!.instantiateViewControllerWithIdentifier("AddLocationViewController") as! AddLocationViewController
		modalPresentationStyle = UIModalPresentationStyle.FullScreen
		modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
		presentViewController(detailController, animated: true, completion: nil)
	}
	
	// Function that is triggered when the user taps the Logout button in the upper-left corner
	@IBAction func doLogout() {
		// Reset the user in the delegate to reflect that no user is logged in
		AppConfiguration.sharedConfiguration.user = nil
		// Get a reference to the Login controller and tehn present it
		let loginController = storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
		modalPresentationStyle = UIModalPresentationStyle.FullScreen
		presentViewController(loginController, animated: true, completion: nil)
	}
	
	// helper function that creates a set of annotations from the data in the studentLocations array, which is sourced by
	// a call to ParseClient to retrieve the most recent 100 posts.
	func createAnnotations() {
		// We will create an MKPointAnnotation for each dictionary in "locations". The
		// point annotations will be stored in this array, and then provided to the map view.
		var annotations = [MKPointAnnotation]()
		
		for dictionary in self.studentLocations! {
			
			// Notice that the float values are being used to create CLLocationDegree values.
			// This is a version of the Double type.
			let lat = CLLocationDegrees(Double(dictionary.latitude!))
			let long = CLLocationDegrees(Double(dictionary.longitude!))
			
			// The lat and long are used to create a CLLocationCoordinates2D instance.
			let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
			
			let first = dictionary.firstName! as String
			let last = dictionary.lastName! as String
			let mediaURL = dictionary.mediaURL! as String
			
			// Here we create the annotation and set its coordinate, title, and subtitle properties
			var annotation = MKPointAnnotation()
			annotation.coordinate = coordinate
			// The title is the name of the user who created the post
			annotation.title = "\(first) \(last)"
			// The subtitle is the URL they included with the post
			annotation.subtitle = mediaURL
			
			// Finally we place the annotation in an array of annotations.
			annotations.append(annotation)
		}
		
		// When the array is complete, we add the annotations to the map. Note that adding the annotations automatically
		// causes the MapView to update and redraw with the new map points.
		self.mapView.addAnnotations(annotations)
	}

	
	// MARK: - MKMapViewDelegate
	
	// Here we create a view with a "right callout accessory view".
	func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
		
		let reuseId = "pin"
		
		var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
		
		if pinView == nil {
			pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
			pinView!.canShowCallout = true
			pinView!.pinColor = .Red
			pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
		}
		else {
			pinView!.annotation = annotation
		}
		
		return pinView
	}
	
	
	// This delegate method is implemented to respond to taps. It opens the system browser
	// to the URL specified in the annotationViews subtitle property.
	func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		
		if control == annotationView.rightCalloutAccessoryView {
			let app = UIApplication.sharedApplication()
			app.openURL(NSURL(string: annotationView.annotation.subtitle!)!)
		}
	}
	
}