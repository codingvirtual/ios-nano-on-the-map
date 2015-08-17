//
//  ParseClient.swift
//  On The Map
//
//  Created by Greg Palen on 8/7/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//

import Foundation

class ParseClient : NSObject {
    
    class func getStudentLocations(completionHandler: (result: AnyObject?, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                println(error)
                completionHandler(result: nil, error: error)
            } else {
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as! NSDictionary
                var objectsArray = parsedResult["results"] as! NSArray
                var locationsArray: [StudentLocation] = [StudentLocation]()
                for item in objectsArray {
                    let location = StudentLocation(studentLocationAsJSON: item as! NSDictionary)
                    locationsArray.append(location)
                }
                completionHandler(result: locationsArray, error: nil)
            }
        }
        task.resume()
    }
}