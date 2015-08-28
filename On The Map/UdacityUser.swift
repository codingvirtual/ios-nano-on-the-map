//
//  UdacityUser.swift
//  On The Map
//
//  Created by Greg Palen on 8/5/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//

import Foundation

struct UdacityUser {
	
	var firstName: String? = nil
	var lastName: String? = nil
	var userId = 0
	
	init(userId: Int) {
		self.userId = userId
	}
	
	init(userId: Int, firstName: String, lastName: String) {
		self.userId = userId
		self.firstName = firstName
		self.lastName = lastName
	}
	
	init(jsonBody: NSDictionary) {
		if let userInfo = jsonBody.valueForKey("user") as? [String:AnyObject] {
			userId = (userInfo[UdacityClient.JSONResponseKeys.UserID] as? String)!.toInt()!
			firstName = userInfo[UdacityClient.JSONResponseKeys.FirstName] as? String
			lastName = userInfo[UdacityClient.JSONResponseKeys.LastName] as? String
		} else {
			// throw a runtime exception for passing bad JSON
		}
	}
}