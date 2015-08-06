//
//  UdacityClient.swift
//  On The Map
//
//  Created by Greg Palen on 8/4/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {
    
    
    /* Authentication state */
    static var sessionID : String?
    static var user: UdacityUser?
    
    override init() {
        super.init()
    }
    
    class func doLogin(userName: String!, password: String?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
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
            if let jsonResult = result as? NSDictionary {
                if let sessionDict = result.valueForKey(Methods.Authorization) as? [String:AnyObject] {
                    UdacityClient.sessionID = sessionDict[JSONResponseKeys.SessionID] as? String
                }
                if let userDict = result.valueForKey("account") as? [String:AnyObject] {
                    UdacityClient.user = UdacityUser(userId: (userDict[JSONResponseKeys.UserID] as? String)!.toInt()!)
                }
                UdacityClient.getUserData(UdacityClient.user!, completionHandler: completionHandler)
            } else {
                completionHandler(result: nil, error: error)
            }
        }
        /* 7. Start the request */
        task.resume()
    }
    
    class func getUserData(user: UdacityUser, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        /* 1. Set the parameters */
        ClientAPILibrary.configure(Constants.BaseURLSecure, baseURLInsecure: Constants.BaseURL)
        var parameters = ["id": UdacityClient.user!.userId]
        
        /* 2/3. Build the URL and configure the request */
        var method = UdacityClient.Methods.GetUserData
        
        
        /* 4. Build the request */
        var task = ClientAPILibrary.taskForSecureGETMethod (Methods.GetUserData, parameters: parameters) {result, error in
            if let jsonResult = result as? NSDictionary {
                if let userInfo = result.valueForKey("user") as? [String:AnyObject] {
                    UdacityClient.user!.firstName = userInfo[JSONResponseKeys.FirstName] as? String
                    UdacityClient.user!.lastName = userInfo[JSONResponseKeys.LastName] as? String
                }
                completionHandler(result: UdacityClient.user as? AnyObject, error: nil)
            } else {
                completionHandler(result: nil, error: error)
            }
        }
        /* 7. Start the request */
        task.resume()
    }
}