//
//  ParseClient.swift
//  On The Map
//
//  Created by Greg Palen on 8/7/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//

//  A client class that leverages the Parse API and the Udacity database of
//  student "locations."

import Foundation
import CoreLocation

class ParseClient : NSObject {
	
	// A class function that queries the Parse API for the most recent 100 student locations that
	// have been posted.
	class func getStudentLocations(completionHandler: ((result: [StudentLocation]?, error: NSError?) -> Void)?) {
		// configure the request
		let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation?order=-updatedAt&limit=100")!)
		// set up the parameters
		request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
		request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
		let session = NSURLSession.sharedSession()
		// construct the request object
		let task = session.dataTaskWithRequest(request) { data, response, error in
			if error != nil { // If an error was returned, this is a network transport error so just return it to the caller
				if (completionHandler != nil) {completionHandler!(result: nil, error: error)}
			} else {
				// A transport error has not occurred, but need to check response code to make sure an HTTP response in the 200 range was received ("OK")
				let serverResponse = response as! NSHTTPURLResponse
				if (serverResponse.statusCode < 200 || serverResponse.statusCode > 299) {
					// Server responded with something not in the 200-OK range, so create an error object and invoke the completionHandler with it if there is one, else return
					let userInfo = NSDictionary(object: "A Server Error Occurred", forKey: NSURLErrorKey)
					if completionHandler != nil {
						completionHandler!(result: nil, error: NSError(domain: "Server", code: serverResponse.statusCode, userInfo: userInfo as [NSObject:AnyObject]))
					}
				} else {  // the result is good and should be Parse data in JSON format
					// First, convert the result to a dictionary for further processing
					let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as! NSDictionary
					// now create an array for easier iteration.
					let objectsArray = parsedResult["results"] as! NSArray
					// instantiate a new array that will contain all the parsed student locations
					var locationsArray = [StudentLocation]()
					// iterate over the objects in the dictionary and add each one to the
					// locations array, which will then be returned via the completionHandler
					// passed in. If no completionHandler was provided, it should be noted
					// that this method just "ends quietly."
					for item in objectsArray {
						locationsArray.append(StudentLocation(dictionary: (item as? [String:AnyObject])!))
					}
					if completionHandler != nil {
						completionHandler!(result: locationsArray, error: nil)
					}
				}
			}
		}
		task.resume()
	}
	
	// A class function that takes a provided location and posts it up to the Udacity database
	// at Parse and uses the Parse API's to do that.
	// Caller provides the location, the string the user entered as their location (that string
	// was used to forward geocode the location that is contained in the first parameter), the
	// URL that the student entered as a resource, and an UdacityUser that will be used to
	// extract the userID, first and last name of the poster.
	// An optional completionHandler can be passed in if further processing needs to be done
	// after the request returns.
	class func doPostStudentLocation(location: CLLocation!, mapString: String!, mediaURL: String!, student: UdacityUser!, completionHandler: ((result: AnyObject?, error: NSError?) -> Void)?) {
		
		// Configure the request
		let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
		// Add parameters
		request.HTTPMethod = "POST"
		request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
		request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		
		// Add JSON body parameter that contains the various values extracted from the data passed in
		let bodyString = "{\"uniqueKey\": \"\(student.userId)\", \"firstName\": \"\(student.firstName!)\", \"lastName\": \"\(student.lastName!)\",\"mapString\": \"\(mapString!)\", \"mediaURL\": \"\(mediaURL!)\",\"latitude\": \(location!.coordinate.latitude), \"longitude\": \(location!.coordinate.longitude)}"
		// add the above to the HTTPBody
		request.HTTPBody = bodyString.dataUsingEncoding(NSUTF8StringEncoding)
		let session = NSURLSession.sharedSession()
		// build the request using all the above data
		let task = session.dataTaskWithRequest(request) { data, response, error in
			if error != nil { // An error occurred with the request; pass it back through the
				// completionHandler
				if (completionHandler != nil) {completionHandler!(result: nil, error: error)}
			} else {
				// no error - the result should be valid JSON indicating success
				let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as! NSDictionary
			if (completionHandler != nil) {completionHandler!(result: parsedResult, error: nil)}
			}
		}
		task.resume()
	}
}