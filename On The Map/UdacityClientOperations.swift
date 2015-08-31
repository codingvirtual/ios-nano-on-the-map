//
//  UdacityClientOperations.swift
//  On The Map
//
//  Created by Greg Palen on 8/4/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//

import UIKit

class UdacityClientOperations: NSObject {
	
	
	/* Authentication state */
	static var sessionID : String?
	
	/* Shared session */
	static var Session: NSURLSession = NSURLSession.sharedSession()
	static var BaseURLSecure: String?
	static var BaseURLInsecure: String?
	
	// class function to configure the URLs for subsequent requests
	// This method MUST be called prior to any methods below or an exception will be raised
	class func configure(baseURLSecure: String, baseURLInsecure: String) {
		BaseURLSecure = baseURLSecure;
		BaseURLInsecure = baseURLInsecure;
	}
	
	// class function that attempts to log in to the Udacity API using the username and
	// password provided. Username is required, password is optional by design, though
	// in practice this is not at all suggested or desired.
	// The caller can *optionally* provide a completionHandler that is executed after the
	// login request is executed. If the login is successful, the error parameter
	// of the completionHandler will be nil.
	class func doLogin(userName: String!, password: String?, completionHandler: ((result: AnyObject!, error: NSError?) -> Void)?) {

		/* 1. Set the parameters - this is handled in the init() of this class */
		configure(Constants.BaseURLSecure, baseURLInsecure: Constants.BaseURL)
		/* 2/3. Build the URL and configure the request */
		let jsonBody: [String:AnyObject] = [
			"udacity":
				[
					"username": userName,
					"password": password
			]
		]
		
		// build a task to go and request a login to the Udacity API, which, if successful,
		// will then trigger a request for the rest of the user's account data.
		
		/* 4. Build the request */
		var task = taskForSecurePOSTMethod (Methods.Authorization, parameters: nil, jsonBody: jsonBody) {result, error in
			if error != nil {  // an error has occurred - return it and stop further processing.
				if completionHandler != nil {
					completionHandler!(result: result, error: error)
				}
			} else {  // the result is good and should be Udacity API data in JSON format
				// The currently logged-in user is stored in the AppDelegate for easy access
				// by the entire app.
				let appDelegate =  UIApplication.sharedApplication().delegate as! AppDelegate
				// the JSON returned by the API should be convertible to a dictionary which
				// is then used to extract user specifics.
				if let jsonResult = result as? NSDictionary {
					// extract the session ID from the JSON
					if let sessionDict = result!.valueForKey(Methods.Authorization) as? [String:AnyObject] {
						UdacityClientOperations.sessionID = sessionDict[JSONResponseKeys.SessionID] as? String
					}
					// extract the Udacity user info from the result
					if let userDict = result!.valueForKey("account") as? [String:AnyObject] {
						// create a new UdacityUser and store in the app delegate. At this point,
						// all that we have is the user's unique userID. In the next step,
						// a request will be initiated to go and retrieve the account data
						// associated with the user which will give us the first and last name.
						appDelegate.user = UdacityUser(userId: (userDict[JSONResponseKeys.UserID] as? String)!.toInt()!)
					}
					// now set up the next request to go fetch the account data which contains
					// the user's first and last name. If a completionHandler was provided in
					// the call this method, then pass it to the next request so it can be
					// called upon ultimate completion, otherwise just go get the user data
					// if no completionHandler was provided.
					if (completionHandler != nil) {
						UdacityClientOperations.getUserData(appDelegate.user, completionHandler: completionHandler)
					} else {
						UdacityClientOperations.getUserData(appDelegate.user!, completionHandler: nil)
					}
				} else { // error parsing data into JSON. If a completionHandler was passed in,
					// invoke it and return the error.
					if (completionHandler != nil) {completionHandler!(result: nil, error: error)}
				}
			}
		}
		/* 7. Start the request */
		task.resume()
	}
	
	// This class function queries the Udacity API for a user's account data which includes
	// the user's first and last name among other info (that is the only data this method
	// actually cares about). This method is called by the login method, though it could be
	// called directly if a valid user object is provided (valid meaning that there is a
	// user account at Udacity with user ID that matches the id of the provided user object)
	class func getUserData(user: UdacityUser!, completionHandler: ((result: AnyObject! , error: NSError?) -> Void)?) {
		// The user info is stored in the app delegate, so retrieve a reference to it
		let appDelegate =  UIApplication.sharedApplication().delegate as! AppDelegate
		/* 1. Set the parameters */
		// Set up the base URL
		configure(Constants.BaseURLSecure, baseURLInsecure: Constants.BaseURL)
		// create a dictionary that contains the userID. This will be used further below
		// to build a JSON body to send with the request.
		var parameters = ["id": appDelegate.user!.userId]
		/* 2/3. Build the URL and configure the request */
		var method = UdacityClientOperations.Methods.GetUserData
		/* 4. Build the request. NOTE: HTTPS is used in this call */
		var task = taskForSecureGETMethod (Methods.GetUserData, parameters: parameters) {result, error in
			if error == nil { // no errors occurred
				if let jsonResult = result as? NSDictionary {	// convert the result to a dictionary
					if let userInfo = result.valueForKey("user") as? [String:AnyObject] {
						// extract the user info from the dictionary and set the appropriate
						// properties of the appDelegate user.
						appDelegate.user!.firstName = userInfo[JSONResponseKeys.FirstName] as? String
						appDelegate.user!.lastName = userInfo[JSONResponseKeys.LastName] as? String
					}
					// if a completionHandler was provided in the call to this method, invoke
					// it and return the user within it
					if (completionHandler != nil) {completionHandler!(result: appDelegate.user! as? AnyObject, error: nil)}
				} else {  // parsing JSON failed. Return the error
					if (completionHandler != nil) {completionHandler!(result: nil, error: error)}
				}
			} else {  // an error occurred getting the user data. return the error
				if completionHandler != nil {completionHandler!(result: nil, error: error)}
			}
		}
		/* 7. Start the request */
		task.resume()
	}
	
	// MARK: - GET (SECURE)
	
	// This method calls the Udacity API to retrieve the user's account info. It may 
	// appear as if the method is configurable, but in reality it is essentially hard-coded
	// to get account info by virtue of the way the dictionary values are used (only the
	// first key/value pair is used and it is expected to contain the user ID for the account
	// This function is PRIVATE as it is for the sole use of the doLogin method above.
	private class func taskForSecureGETMethod(method: String, parameters: [String : AnyObject]?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
		var expandedMethod = subtituteKeyInMethod(method, key: parameters!.keys.first!, value: (parameters!.values.first as? Int)!.description)
		/* 1,2,3. Set the parameters, Build the URL and Configure the request */
		var urlString = BaseURLInsecure! + expandedMethod!
		let url = NSURL(string: urlString)!
		let request = NSURLRequest(URL: url)
		/* 4. Build the request */
		let task = Session.dataTaskWithRequest(request) {data, response, downloadError in
			/* 5/6. Parse the data and use the data (happens in completion handler) */
			if let error = downloadError {
				let newError = self.errorForData(data, response: response, error: error)
				completionHandler(result: nil, error: downloadError)
			} else {
				// For the JSON that the Udacity API returns, the first 5 characters must be
				// stripped off due to the way the server provides the data. Below, we
				// strip those characters off then parse as JSON like one would normally do.
				let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5 )) /* subset response data! */
				self.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
			}
		}
		return task
	}
	
	
	// MARK: - POST (SECURE)
	
	// This function is specifically configured to handle the login request to the Udacity API
	// and is hardcoded to use the HTTPS-based URL (secure) since the user's credentials are
	// contained in the JSON body and we need to encrypt those credentials in the login attempt.
	// This class is PRIVATE as it is for the sole use of the doLogin method above.
	private class func taskForSecurePOSTMethod(method: String, parameters: [String : AnyObject]?, jsonBody: [String:AnyObject]?, completionHandler: ((result: AnyObject?, error: NSError?) -> Void)?) -> NSURLSessionDataTask {
		/* 1,2,3. Set the parameters, Build the URL and Configure the request */
		var urlString = BaseURLSecure! + method
		if let mutableParameters = parameters {
			urlString = urlString.stringByAppendingString(escapedParameters(mutableParameters))
		}
		let url = NSURL(string: urlString)!
		let request = NSMutableURLRequest(URL: url)
		var jsonifyError: NSError? = nil
		request.HTTPMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody!, options: nil, error: &jsonifyError)
		/* 4. Build the request */
		let task = Session.dataTaskWithRequest(request) { data, response, downloadError in
			/* 5/6. Parse the data and use the data (happens in completion handler) */
			// There are 3 possible states we could be in at this point in the code:
			//		a) There was a transport error (a lower level error that occurred
			//			within the networking layer itself.
			//		b) The request was processed, but there was some sort of API Server
			//			error that occurred, possibly because of bad data that was in
			//			our request to the server
			//		c) The request was processed and "good" data was returned by the server
			
			if let error = downloadError {  // a transport-related error has occurred
				let newError = self.errorForData(data, response: response, error: error)
				if completionHandler != nil {
					completionHandler!(result: nil, error: newError)
				}
			} else {
				// A transport error has not occurred, but need to check response code to make 
				// sure an HTTP response in the 200 range was received, which indicates an "OK" 
				// status and we should expect valid JSON data to have been returned.
				
				let serverResponse = response as! NSHTTPURLResponse
				if (serverResponse.statusCode < 200 || serverResponse.statusCode > 299) {
					// Server responded with something not in the 200-OK range, so create an error object and invoke the completionHandler with it if there is one, else return
					var userInfo: NSDictionary? = nil
					if serverResponse.statusCode == 403 { // bad login
						userInfo = NSDictionary(object: "Username/Password combination is invalid. Please try again", forKey: NSURLErrorKey)
					} else {  // some other server error
						userInfo = NSDictionary(object: "A Server Error Occurred", forKey: NSURLErrorKey)
					}
					// If a completionHandler was passed in, invoke it now with the appropriate
					// error message set.
					if (completionHandler != nil) {
						let newError = NSError(domain: "Server", code: serverResponse.statusCode, userInfo: userInfo! as [NSObject:AnyObject])
						completionHandler!(result: nil, error: newError)
					}
				} else { // data is good - process it
					// Udacity API returns a response with 5 characters at the beginning that
					// are not part of the actual JSON response. Strip those 5 characters off
					// and then continue parsing JSON as usual.
					let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
					if completionHandler != nil {
						self.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler!)
					}
				}
			}
		}
		return task
	}
	
	// MARK: - Helpers
	
	
	/* Helper: Substitute the key for the value that is contained within the method name */
	class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
		if method.rangeOfString("{\(key)}") != nil {
			return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
		} else {
			return nil
		}
	}
	
	/* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
	class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
		if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String : AnyObject] {
			if let errorMessage = parsedResult[UdacityClientOperations.JSONResponseKeys.StatusMessage] as? String {
				let userInfo = [NSLocalizedDescriptionKey : errorMessage]
				return NSError(domain: "Udacity Error", code: 1, userInfo: userInfo)
			}
		}
		return error
	}
	
	/* Helper: Given raw JSON, pass a usable Foundation object to the supplied completionHandler */
	class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
		var parsingError: NSError? = nil
		let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
		if let error = parsingError {
			completionHandler(result: nil, error: error)
		} else {
			completionHandler(result: parsedResult, error: nil)
		}
	}
	
	/* Helper function: Given a dictionary of parameters, convert to a string for a url */
	class func escapedParameters(parameters: [String : AnyObject]) -> String {
		var urlVars = [String]()
		for (key, value) in parameters {
			/* Make sure that it is a string value */
			let stringValue = "\(value)"
			/* Escape it */
			let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
			/* Append it */
			urlVars += [key + "=" + "\(escapedValue!)"]
		}
		return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
	}
}