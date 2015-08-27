//
//  ParseClient.swift
//  On The Map
//
//  Created by Greg Palen on 8/7/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//

import Foundation
import CoreLocation

//  TODO:
//  Does the app indicate activity during the geocoding?
//  Required: • An activity indicator is displayed during geocoding, and returns to normal state on completion.
//  Udacious: • The app shows additional indications of activity, such as modifying alpha/transparency of interface elements.

class ParseClient : NSObject {
    
    class func getStudentLocations(completionHandler: ((result: [StudentLocation]?, error: NSError?) -> Void)?) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation?order=-createdAt&limit=100")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
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
                    let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as! NSDictionary
                    var objectsArray = parsedResult["results"] as! NSArray
                    var locationsArray = [StudentLocation]()
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
    
    class func doPostStudentLocation(location: CLLocation!, mapString: String!, mediaURL: String!, student: UdacityUser!, completionHandler: ((result: AnyObject?, error: NSError?) -> Void)?) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let bodyString = "{\"uniqueKey\": \"\(student.userId)\", \"firstName\": \"\(student.firstName!)\", \"lastName\": \"\(student.lastName!)\",\"mapString\": \"\(mapString!)\", \"mediaURL\": \"\(mediaURL!)\",\"latitude\": \(location!.coordinate.latitude), \"longitude\": \(location!.coordinate.longitude)}"
        println(bodyString)
        request.HTTPBody = bodyString.dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                println("error in doPostStudentLocation task result")
                if (completionHandler != nil) {completionHandler!(result: nil, error: error)}
            }
            println("Successful post of student location")
            let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as! NSDictionary
            if (completionHandler != nil) {completionHandler!(result: parsedResult, error: nil)}
        }
        task.resume()
    }
}