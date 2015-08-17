//
//  StudentLocation.swift
//  On The Map
//
//  Created by Greg Palen on 8/6/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//

import Foundation
import Parse

class StudentLocation: NSObject {
    
     var uniqueKey: String?
     var firstName: String?
     var lastName: String?
     var mapString: String?
     var mediaURL: String?
     var latitude: Float?
     var longitude: Float?

    init(studentLocationAsJSON: NSDictionary) {
        self.uniqueKey = studentLocationAsJSON.valueForKey("uniqueKey") as? String
        self.firstName = studentLocationAsJSON.valueForKey("firstName") as? String
        self.lastName = studentLocationAsJSON.valueForKey("lastName") as? String
        self.mapString = studentLocationAsJSON.valueForKey("mapString") as? String
        self.mediaURL = studentLocationAsJSON.valueForKey("mediaURL") as? String
        self.latitude = studentLocationAsJSON.valueForKey("latitude") as? Float
        self.longitude = studentLocationAsJSON.valueForKey("longitude") as? Float
    }
}
