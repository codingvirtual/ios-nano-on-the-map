//
//  UdacityClient.swift
//  On The Map
//
//  Created by Greg Palen on 8/4/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//

import UIKit

class UdacityClient: NSObject {
	
	
	/* Authentication state */
	static var sessionID : String?
	static var user: UdacityUser?
	
	/* Shared session */
	static var Session: NSURLSession = NSURLSession.sharedSession()
	static var BaseURLSecure: String?
	static var BaseURLInsecure: String?
	
	class func configure(baseURLSecure: String, baseURLInsecure: String) {
		BaseURLSecure = baseURLSecure;
		BaseURLInsecure = baseURLInsecure;
	}
	
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
		/* 4. Build the request */
		var task = taskForSecurePOSTMethod (Methods.Authorization, parameters: nil, jsonBody: jsonBody) {result, error in
			if error != nil {  // an error has occurred - return it and stop further processing.
				if completionHandler != nil {
					completionHandler!(result: result, error: error)
				}
			} else {  // the result is good and should be Parse data in JSON format
				let object = UIApplication.sharedApplication().delegate
				let appDelegate =  object as! AppDelegate
				if let jsonResult = result as? NSDictionary {
					if let sessionDict = result!.valueForKey(Methods.Authorization) as? [String:AnyObject] {
						UdacityClient.sessionID = sessionDict[JSONResponseKeys.SessionID] as? String
					}
					if let userDict = result!.valueForKey("account") as? [String:AnyObject] {
						appDelegate.user = UdacityUser(userId: (userDict[JSONResponseKeys.UserID] as? String)!.toInt()!)
					}
					if (completionHandler != nil) {
						UdacityClient.getUserData(appDelegate.user, completionHandler: completionHandler)
					} else {
						UdacityClient.getUserData(appDelegate.user!, completionHandler: nil)
					}
				} else { // error parsing data into JSON
					if (completionHandler != nil) {completionHandler!(result: nil, error: error)}
				}
			}
		}
		/* 7. Start the request */
		task.resume()
	}
	
	class func getUserData(user: UdacityUser!, completionHandler: ((result: AnyObject! , error: NSError?) -> Void)?) {
		let object = UIApplication.sharedApplication().delegate
		let appDelegate =  object as! AppDelegate
		/* 1. Set the parameters */
		configure(Constants.BaseURLSecure, baseURLInsecure: Constants.BaseURL)
		var parameters = ["id": appDelegate.user!.userId]
		/* 2/3. Build the URL and configure the request */
		var method = UdacityClient.Methods.GetUserData
		/* 4. Build the request */
		var task = taskForSecureGETMethod (Methods.GetUserData, parameters: parameters) {result, error in
			if error == nil { // no errors occurred
				if let jsonResult = result as? NSDictionary {
					if let userInfo = result.valueForKey("user") as? [String:AnyObject] {
						appDelegate.user!.firstName = userInfo[JSONResponseKeys.FirstName] as? String
						appDelegate.user!.lastName = userInfo[JSONResponseKeys.LastName] as? String
					}
					if (completionHandler != nil) {completionHandler!(result: user! as? AnyObject, error: nil)}
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
	
	class func taskForSecureGETMethod(method: String, parameters: [String : AnyObject]?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
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
				let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5 )) /* subset response data! */
				self.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
			}
		}
		return task
	}
	
	
	// MARK: - POST (SECURE)
	
	class func taskForSecurePOSTMethod(method: String, parameters: [String : AnyObject]?, jsonBody: [String:AnyObject]?, completionHandler: ((result: AnyObject?, error: NSError?) -> Void)?) -> NSURLSessionDataTask {
		/* 1,2,3. Set the parameters, Build the URL and Configure the request */
		var urlString = BaseURLInsecure! + method
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
			if let error = downloadError {  // a transport-related error has occurred
				let newError = self.errorForData(data, response: response, error: error)
				if completionHandler != nil {
					completionHandler!(result: nil, error: newError)
				}
			} else {
				// A transport error has not occurred, but need to check response code to make sure an HTTP response in the 200 range was received ("OK")
				let serverResponse = response as! NSHTTPURLResponse
				if (serverResponse.statusCode < 200 || serverResponse.statusCode > 299) {
					// Server responded with something not in the 200-OK range, so create an error object and invoke the completionHandler with it if there is one, else return
					var userInfo: NSDictionary? = nil
					if serverResponse.statusCode == 403 { // bad login
						userInfo = NSDictionary(object: "Username/Password combination is invalid. Please try again", forKey: NSURLErrorKey)
					} else {  // some other server error - pass it back
						userInfo = NSDictionary(object: "A Server Error Occurred", forKey: NSURLErrorKey)
					}
					if (completionHandler != nil) {
						let newError = NSError(domain: "Server", code: serverResponse.statusCode, userInfo: userInfo! as [NSObject:AnyObject])
						completionHandler!(result: nil, error: newError)
					}
				} else { // data is good - process it
					let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
					self.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler!)
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
			if let errorMessage = parsedResult[UdacityClient.JSONResponseKeys.StatusMessage] as? String {
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
	
	// MARK: - Shared Instance
	
	class func sharedInstance() -> UdacityClient {
		struct Singleton {
			static var sharedInstance = UdacityClient()
		}
		return Singleton.sharedInstance
	}
}