//
//  ClientAPILibrary.swift
//  On The Map
//
//  Created by Greg Palen on 8/4/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//

import Foundation

class ClientAPILibrary: NSObject {
    
    /* Shared session */
    static var Session: NSURLSession = NSURLSession.sharedSession()
    static var BaseURLSecure: String?
    static var BaseURLInsecure: String?

    class func configure(baseURLSecure: String, baseURLInsecure: String) {
        BaseURLSecure = baseURLSecure;
        BaseURLInsecure = baseURLInsecure;
    }
    
    // MARK: - GET (Insecure)
    
    class func taskForInsecureGETMethod(method: String, parameters: [String : AnyObject]?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        /* 1. Set the parameters */
        
        /* 2/3. Build the URL and configure the request */
        var urlString = ClientAPILibrary.BaseURLInsecure! + method
        if let mutableParameters = parameters {
            urlString = urlString.stringByAppendingString(ClientAPILibrary.escapedParameters(mutableParameters))
        }
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        /* 4. Make the request */
        let task = Session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                let newError = ClientAPILibrary.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: downloadError)
            } else {
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                ClientAPILibrary.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        }
       
        return task
    }
    
    // MARK: - GET (SECURE)
    
    class func taskForSecureGETMethod(method: String, parameters: [String : AnyObject]?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var urlString = ClientAPILibrary.BaseURLInsecure! + method
        if let mutableParameters = parameters {
            urlString = urlString.stringByAppendingString(ClientAPILibrary.escapedParameters(mutableParameters))
        }
        
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        /* 4. Make the request */
        let task = Session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                let newError = ClientAPILibrary.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: downloadError)
            } else {
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                ClientAPILibrary.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        }
        
        return task
    }
   
    // MARK: - POST (Insecure)
    
    class func taskForInsecurePOSTMethod(method: String, parameters: [String : AnyObject]?, jsonBody: [String:AnyObject]?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var urlString = ClientAPILibrary.BaseURLInsecure! + method
        if let mutableParameters = parameters {
            urlString = urlString.stringByAppendingString(ClientAPILibrary.escapedParameters(mutableParameters))
        }
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        var jsonifyError: NSError? = nil
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody!, options: nil, error: &jsonifyError)
        
        /* 4. Make the request */
        let task = Session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                let newError = ClientAPILibrary.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: downloadError)
            } else {
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                ClientAPILibrary.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        }
       
        return task
    }
    
    // MARK: - POST (SECURE)
    
    class func taskForSecurePOSTMethod(method: String, parameters: [String : AnyObject]?, jsonBody: [String:AnyObject]?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var urlString = BaseURLInsecure! + method
        if let mutableParameters = parameters {
            urlString = urlString.stringByAppendingString(ClientAPILibrary.escapedParameters(mutableParameters))
        }
        
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        var jsonifyError: NSError? = nil
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody!, options: nil, error: &jsonifyError)
        
        /* 4. Make the request */
        let task = Session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                let newError = ClientAPILibrary.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: downloadError)
            } else {
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                ClientAPILibrary.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
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
            
            // TODO: Fix below reference to UdacityClient
            if let errorMessage = parsedResult[UdacityClient.JSONResponseKeys.StatusMessage] as? String {
                
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                return NSError(domain: "Udacity Error", code: 1, userInfo: userInfo)
            }
        }
        
        return error
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
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
    
    class func sharedInstance() -> ClientAPILibrary {
        
        struct Singleton {
            static var sharedInstance = ClientAPILibrary()
        }
        
        return Singleton.sharedInstance
    }
}