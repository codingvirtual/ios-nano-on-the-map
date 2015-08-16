//
//  RequestBuilder.swift
//  On The Map
//
//  Created by Greg Palen on 8/9/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//

import Foundation

class RequestBuilder {
    var parameters: [String:AnyObject]? = nil
    var url: String? = nil
    var jsonBody: [String:AnyObject]? = nil
    var completionHandler: ((result: AnyObject!, error: NSError?) -> Void)? = nil
    var HTTPMethod: String = "GET"
    
    init (url: String!, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        self.url = url;
        self.completionHandler = completionHandler
    }
    
    func setParameters (parameters: [String:AnyObject]) -> RequestBuilder {
        self.parameters = parameters
        return self
    }
    
    func setJsonBody (jsonBody: [String: AnyObject]) -> RequestBuilder {
        self.jsonBody = jsonBody
        return self
    }
    
    func setMethod(method: String?) -> RequestBuilder {
        self.HTTPMethod = method!
        return self
    }
    
    func build(session: NSURLSession) -> NSURLSessionDataTask {
        var parametersString: String? = nil
        subtituteKeysInMethod()
        if let parameters = self.parameters {
            parametersString = RequestBuilder.escapedParameters(parameters)
            url = url!.stringByAppendingString(parametersString!)
        }
        let request = NSMutableURLRequest(URL: NSURL(string: url!)!)
        if (jsonBody != nil) {
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody!, options: nil, error: nil)
        }
        request.HTTPMethod = self.HTTPMethod
        return session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                self.completionHandler!(result: nil, error: error)
            } else {
                self.completionHandler!(result: response, error: nil)
            }
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
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    func subtituteKeysInMethod() {
        if let parameters = self.parameters {
            for (key, value) in self.parameters! {
                if self.url!.rangeOfString("{\(key)}") != nil {
                    self.url = self.url!.stringByReplacingOccurrencesOfString("{\(key)}", withString: value as! String)
                    self.parameters?.updateValue(value, forKey: key)
                    self.parameters?.removeValueForKey(key)
                }
            }
        }
    }
}