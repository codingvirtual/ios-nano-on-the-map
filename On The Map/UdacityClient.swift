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
	
	class func doLogin(userName: String!, password: String?, completionHandler: ((result: AnyObject!, error: NSError?) -> Void)?) {
		/* 1. Set the parameters - this is handled in the init() of this class */
		ClientAPILibrary.configure(Constants.BaseURLSecure, baseURLInsecure: Constants.BaseURL)
		
		/* 2/3. Build the URL and configure the request */
		let jsonBody: [String:AnyObject] = [
			"udacity":
				[
					"username": userName,
					"password": password
			]
		]
		
		/* 4. Build the request */
		var task = ClientAPILibrary.taskForSecurePOSTMethod (Methods.Authorization, parameters: nil, jsonBody: jsonBody) {result, error in
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
		ClientAPILibrary.configure(Constants.BaseURLSecure, baseURLInsecure: Constants.BaseURL)
		var parameters = ["id": appDelegate.user!.userId]
		
		/* 2/3. Build the URL and configure the request */
		var method = UdacityClient.Methods.GetUserData
		
		
		/* 4. Build the request */
		var task = ClientAPILibrary.taskForSecureGETMethod (Methods.GetUserData, parameters: parameters) {result, error in
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
	
}