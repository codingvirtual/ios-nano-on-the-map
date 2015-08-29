//: Playground - noun: a place where people can play

import UIKit
import CoreLocation


var str = "Hello, playground"

var locations = CLGeocoder()

locations.geocodeAddressString("Kimberling City, MO", completionHandler: {(placemarks: [AnyObject]!, error: NSError!) in
    if error != nil {
        println("Geocode failed with error: \(error.localizedDescription)")
    } else if placemarks.count > 0 {
        let placemark = placemarks[0] as! CLPlacemark
        let location = placemark.location
        println("coordinates: \(location.coordinate)")
    }
})
