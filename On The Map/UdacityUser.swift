//
//  UdacityUser.swift
//  On The Map
//
//  Created by Greg Palen on 8/5/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//

//	This struct represents an Udacity user/student within the Udacity API. It does
//	*not* contain all possible data that the Udacity API can return via getData, but
//	instead encapsulates only those fields this application makes use of.

//	NOTE: when using the form of init that takes a dictionary, be sure to check the
//	returned object is NOT nil. If the initializer fails to find a key named "user"
//	it will return nil, which may not be what you are expecting.

import Foundation

struct UdacityUser {
	
	var firstName: String? = nil		// The user's first and last name
	var lastName: String? = nil
	var userId = 0						// Udacity's user ID (unique to each user) for this person
	
	init(userId: Int) {
		// Initializer that requires only the userID. It is expected that the code using this
		// would populate the first and last name separately or later.
		self.userId = userId
	}
	
	init(userId: Int, firstName: String, lastName: String) {
		// Initializer that allows all properties to be passed explicitly. Used mainly for 
		// testing.
		self.userId = userId
		self.firstName = firstName
		self.lastName = lastName
	}
	
	init?(jsonBody: NSDictionary) {
		// Initializer that takes an NSDictionary (such as what is returned by the Udacity API
		// and populates the properties based on the key/value pairs contained within the dictionary
		if let userInfo = jsonBody.valueForKey("user") as? [String:AnyObject] {
			userId = (userInfo[UdacityClientOperations.JSONResponseKeys.UserID] as? String)!.toInt()!
			firstName = userInfo[UdacityClientOperations.JSONResponseKeys.FirstName] as? String
			lastName = userInfo[UdacityClientOperations.JSONResponseKeys.LastName] as? String
		} else {
			// if there was no "user" key in the provided dictionary, return nil to indicate an
			// error
			return nil
		}
	}
}