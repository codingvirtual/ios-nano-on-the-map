//
//  GetLinkViewController.swift
//  On The Map
//
//  Created by Greg Palen on 8/19/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//


//  Note that UIViewController is extended by UIViewControllerExtension.swift which contains
//  the code to raise an AlertView by any of the view controllers in this application.

import Foundation
import CoreLocation
import UIKit
import MapKit

class GetLinkViewController: UIViewController, MKMapViewDelegate  {
	
	var userLocation: CLLocation?
	var mapString: String?
	var mediaURL: String?
	var student: UdacityUser?
	var previousController: AddLocationViewController?
	
	@IBOutlet weak var linkTF: UITextField!
	
	@IBOutlet weak var mapView: MKMapView!
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		let object = UIApplication.sharedApplication().delegate
		let appDelegate = object as! AppDelegate
		student = appDelegate.user!
	}
	
	@IBAction func doCancel() {
		self.dismissViewControllerAnimated(false, completion: {() in
			self.previousController!.dismissViewControllerAnimated(true, completion: nil)
		})
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let locationAnnotation = MKPointAnnotation()
		locationAnnotation.coordinate = userLocation!.coordinate
		mapView.addAnnotation(locationAnnotation)
		mapView.centerCoordinate = userLocation!.coordinate
	}
	
	
	@IBAction func doSubmit(sender: AnyObject) {
		mediaURL = linkTF.text
		if isValid(mediaURL) {
			ParseClient.doPostStudentLocation(userLocation, mapString: mapString, mediaURL: mediaURL, student: student) {(result, error) in
				if error == nil {
					dispatch_async(dispatch_get_main_queue(), { () in
						self.showAlert("Success!", message: "Your post was added successfully") { () in
							self.doCancel()
						}
					})
					
				} else {
					dispatch_async(dispatch_get_main_queue(), { () in
						self.showAlert("ERROR!", message: "An error occurred when trying to post: \(error!.description)")
					})
				}
			}
		} else {
			showAlert("URL Invalid", message: "The URL you entered is invalid or blank. Please check the URL and try again.")
		}
	}
	
	
	func isValid (url: String!) -> Bool {
		let regex = "^(https?://)?([a-zA-Z0-9-]+[.])*([a-zA-Z0-9-])+[.][a-zA-Z]{2,3}(/.*)?$"
		return url.rangeOfString(regex, options: NSStringCompareOptions.RegularExpressionSearch) != nil
	}
	
	
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
	
	
	// This delegate method is implemented to respond to taps. It opens the system browser
	// to the URL specified in the annotationViews subtitle property.
	func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		
		if control == annotationView.rightCalloutAccessoryView {
			return
		}
	}
}