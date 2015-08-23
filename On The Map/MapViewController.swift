//
//  MapViewController.swift
//  On The Map
//
//  Created by Greg Palen on 8/18/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//

import Foundation
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // The map. See the setup in the Storyboard file. Note particularly that the view controller
    // is set up as the map view's delegate.
    @IBOutlet weak var mapView: MKMapView!
    
    // The "studentLocations" array is an array of dictionary objects that are downloaded from Parse
    var studentLocations: [StudentLocation]?
    var appDelegate: AppDelegate!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let object = UIApplication.sharedApplication().delegate
        self.appDelegate = object as! AppDelegate
        
        ParseClient.getStudentLocations() {result, error in
            self.studentLocations = result as? [StudentLocation]
            dispatch_async(dispatch_get_main_queue(), { () in
                self.getLocations()
                println("locations updated")
            })
        }
    }
    
    func getLocations() {
        // The "locations" array is loaded with the sample data below. We are using the dictionaries
        // to create map annotations. This would be more stylish if the dictionaries were being
        // used to create custom structs. Perhaps StudentLocation structs.
        
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
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            var annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        
        // When the array is complete, we add the annotations to the map.
        self.mapView.addAnnotations(annotations)
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var barButtonItems = [UIBarButtonItem]()
        barButtonItems.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "doRefresh"))
        barButtonItems.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "doAddLocation"))
        self.navigationItem.rightBarButtonItems = barButtonItems
    }
    
    func doRefresh() {
        mapView.removeAnnotations(mapView.annotations)
        ParseClient.getStudentLocations() {result, error in
            self.studentLocations = result as? [StudentLocation]
            dispatch_async(dispatch_get_main_queue(), { () in
                self.getLocations()
                self.view.makeToast(message: "Locations have been updated", duration: HRToastDefaultDuration, position: HRToastPositionCenter)
            })

        }
    }
    
    func showAlert() {
        let alertController = UIAlertController()
        alertController.title = "Alert"
        alertController.message = "Here is an alert message"
        
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.Default) { action in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func doAddLocation() {
        println("add location")
        let detailController = storyboard!.instantiateViewControllerWithIdentifier("AddLocationViewController") as! AddLocationViewController
        modalPresentationStyle = UIModalPresentationStyle.FullScreen
        modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        presentViewController(detailController, animated: true, completion: nil)
    }
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
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