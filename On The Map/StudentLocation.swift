//
//  StudentLocation.swift
//  On The Map
//
//  Created by Greg Palen on 8/6/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//

import Foundation
import Parse

struct StudentLocation {
//class StudentLocation: NSObject {

     var uniqueKey: String? = nil
     var firstName: String? = nil
     var lastName: String? = nil
     var mapString: String? = nil
     var mediaURL: String? = nil
     var latitude: Float? = nil
     var longitude: Float? = nil
   
    init(dictionary: [String : AnyObject]) {
        uniqueKey = dictionary["uniqueKey"] as? String
        firstName = dictionary["firstName"] as? String
        lastName = dictionary["lastName"] as? String
        mapString = dictionary["mapString"] as? String
        mediaURL = dictionary["mediaURL"] as? String
        latitude = dictionary["latitude"] as? Float
        longitude = dictionary["longitude"] as? Float
    }
}
