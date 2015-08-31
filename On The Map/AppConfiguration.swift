//
//  AppConfiguration.swift
//  On The Map
//
//  Created by Greg Palen on 8/31/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//

import Foundation

public class AppConfiguration {
	
	// A reference to the currently logged-in user
	var user: UdacityUser? = nil
	// List of student posting locations - the ultimate data source for the table
	var studentLocations: [StudentLocation]? = nil
	
	public class var sharedConfiguration: AppConfiguration {
		struct Singleton {
			static let sharedAppConfiguration = AppConfiguration()
		}
		
		return Singleton.sharedAppConfiguration
	}
}