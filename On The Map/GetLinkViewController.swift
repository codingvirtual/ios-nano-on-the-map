//
//  GetLinkViewController.swift
//  On The Map
//
//  Created by Greg Palen on 8/19/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import MapKit

class GetLinkViewController: UIViewController, MKMapViewDelegate  {
    
    var userLocation: CLLocation?
    var mapString: String?
    var mediaURL: String?
    var student: UdacityUser?
    
    @IBOutlet weak var linkTF: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        //student = appDelegate.user!
        student = UdacityUser(userId: 9999, firstName: "Greg", lastName: "The Test Guy")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("Location received \(userLocation!.description)")
        let locationAnnotation = MKPointAnnotation()
        locationAnnotation.coordinate = userLocation!.coordinate
        mapView.addAnnotation(locationAnnotation)
        mapView.centerCoordinate = userLocation!.coordinate
    }
   
    
    @IBAction func doSubmit(sender: AnyObject) {
        mediaURL = linkTF.text
        ParseClient.doPostStudentLocation(userLocation, mapString: mapString, mediaURL: mediaURL, student: student) {(result, error) in
            if error == nil {

                dispatch_async(dispatch_get_main_queue(), { () in
                    self.showAlert("Success!", message: "Your post was added successfully")
                })

            } else {
                dispatch_async(dispatch_get_main_queue(), { () in
                    self.showAlert("ERROR!", message: "An error occurred when trying to post: \(error!.description)")
                })
            }
        }
    }
    
    func showAlert(title: String?, message: String?) {
        let alertController = UIAlertController()
        if title != nil {alertController.title = title} else {alertController.title = "This alert needs a title!"}
        if message != nil {alertController.message = message} else {alertController.message = "This alert needs a message!"}
        
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.Default) { action in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
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