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

    @IBOutlet weak var locationTV: UITextField!
    
    @IBOutlet weak var findLocation: UIButton!
    
    override func viewDidLoad() {
        locationTV.delegate = self
        findLocation.enabled = false;
        findLocation.setTitle("Enter Location", forState: UIControlState.Disabled)
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
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if locationTV.text.isEmpty {
            findLocation!.enabled = false
        } else {
            findLocation!.enabled = true
        }
        return true;
    }
    
    func getLocation() {
        var locations = CLGeocoder()
        
        locations.geocodeAddressString(locationTV.text, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) in
            if error != nil {
                self.showAlert("Geocoding has failed!", message: error.description)
            } else if placemarks.count > 0 {
                let placemark = placemarks[0] as! CLPlacemark
                let location = placemark.location
                self.showLinkController(location)
                // self.showAlert("Geocoding succeeded!", message: location.description)
            }
        })
    }
    
    func showAlert(title: String?, message: String?) {
        let alertController = UIAlertController()
        if title != nil {alertController.title = title} else {alertController.title = "This alert needs a title!"}
        if message != nil {alertController.message = message} else {alertController.message = "This alert needs a message!"}
        
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.Default) { action in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showLinkController(location: CLLocation!) {
        let linkController = storyboard!.instantiateViewControllerWithIdentifier("GetLinkViewController") as! GetLinkViewController
        linkController.location = location
        self.presentViewController(linkController, animated: true, completion: nil)
        
    }
    
}