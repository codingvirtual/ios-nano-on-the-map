//
//  StudentLocation.swift
//  On The Map
//
//  Created by Greg Palen on 8/6/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//

// This struct represents a single "location" that an Udacity student has posted
// to Udacity's Parse database. Each instance of this struct will be rendered
// as an AnnotationView on the MapView controlled by MapViewController

import Foundation
import Parse

struct StudentLocation {
	
	var uniqueKey: String? = nil	// database key. Auto-assigned by Parse on creation
	var firstName: String? = nil	// first name of the student who posted this location
	var lastName: String? = nil		// last name of the student
	var mapString: String? = nil	// The text the user entered as their current location
	var mediaURL: String? = nil		// The URL the user entered
	var latitude: Float? = nil		// The latitude and longitude that resulted from the
	var longitude: Float? = nil		//	 forward geocode of the mapString above
	
	init(dictionary: [String : AnyObject]) {
		// Initializer that takes a dictionary and populates the properties based on the keys
		uniqueKey = dictionary["uniqueKey"] as? String
		firstName = dictionary["firstName"] as? String
		lastName = dictionary["lastName"] as? String
		mapString = dictionary["mapString"] as? String
		mediaURL = dictionary["mediaURL"] as? String
		latitude = dictionary["latitude"] as? Float
		longitude = dictionary["longitude"] as? Float
	}
}
