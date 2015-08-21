//
//  ParseClient.swift
//  On The Map
//
//  Created by Greg Palen on 8/7/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//

import Foundation
import CoreLocation

class ParseClient : NSObject {
    
    class func getStudentLocations(completionHandler: ((result: AnyObject?, error: NSError?) -> Void)?) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation?")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                println(error)
                if (completionHandler != nil) {completionHandler!(result: nil, error: error)}
            } else {
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as! NSDictionary
                var objectsArray = parsedResult["results"] as! NSArray
                var locationsArray: [StudentLocation] = [StudentLocation]()
                for item in objectsArray {
                    let location = StudentLocation(studentLocationAsJSON: item as! NSDictionary)
                    locationsArray.append(location)
                }
                if (completionHandler != nil) {completionHandler!(result: locationsArray, error: nil)}
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