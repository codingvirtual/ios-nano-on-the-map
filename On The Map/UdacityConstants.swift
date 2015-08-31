//
//  UdacityConstants.swift
//  On The Map
//
//  Created by Greg Palen on 8/4/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//

//	A set of constants used in calls to the Udacity API.
//	This file EXTENDS the UdacityClientOperations class.

extension UdacityClientOperations {
	
	// MARK: - Constants
	struct Constants {
		
		// MARK: URLs
		// The URLs to access the API. It is STRONGLY advised NOT to use
		// the insecure version.
		static let BaseURL : String = "http://www.udacity.com/api/"
		static let BaseURLSecure : String = "https://www.udacity.com/api/"
		
	}
	
	// MARK: - Methods
	// Strings that represent path terms appended to the end of the base
	// URL to form a more complete URL request.
	struct Methods {
		
		// MARK: Login
		// Path to create a session, which invokes the login action
		static let Authorization: String = "session"
		
		// MARK: Session
		// Key to retrieve info about a specific user. The UserID
		// is the value, and this is the key to access that value with
		static let UserID: String = "key"
		
		// MARK: Public User Data
		// The path to obtain the full set of data for a given user
		static let GetUserData: String = "users/{id}"
		
	}
	
	// MARK: - Parameter Keys
	struct ParameterKeys {
		
		// Keys used in a dictionary to identify the session and userID
		// Routines in the UdacityClientOperations.swift file use these
		// keys to extract or provide the associated values
		static let SessionID = "id"
		static let UserID = "key"
		
	}
	
	// MARK: - JSON Body Keys
	struct JSONBodyKeys {
		
		// Keys used to provide the associated values to the routines
		// the create a request to the Udacity API to log in. These keys
		// are used to extract the values so they can be used to 
		// generate a serialized JSON body representing the values.
		static let UserName = "username"
		static let Password = "password"
		static let Key = "key"
		
	}
	
	// MARK: - JSON Response Keys
	struct JSONResponseKeys {
		
		// Keys used to extract various pieces of data from the HTTP request
		// response (either from the header or from the JSON data).
		
		// MARK: General
		static let StatusMessage = "status_message"
		static let StatusCode = "status_code"
		
		// MARK: Session
		static let SessionID = "id"
		
		// MARK: Account
		static let UserID = "key"
		
		// MARK: Public User Data
		static let FirstName = "first_name"
		static let LastName = "last_name"
		
	}
}