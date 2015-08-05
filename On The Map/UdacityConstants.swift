//
//  UdacityConstants.swift
//  On The Map
//
//  Created by Greg Palen on 8/4/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//


extension UdacityClient {
    
    // MARK: - Constants
    struct Constants {
        
        // MARK: URLs
        static let BaseURL : String = "http://www.udacity.com/api/"
        static let BaseURLSecure : String = "https://www.udacity.com/api/"
        
    }
    
    // MARK: - Methods
    struct Methods {
        
        // MARK: Login
        static let Authorization: String = "session"
        
        // MARK: Session
        static let SessionToken = "authentication/token/new"

    }
    
    // MARK: - Parameter Keys
    struct ParameterKeys {
        
        static let SessionID = "session_id"
        static let RequestToken = "request_token"
        
    }
    
    // MARK: - JSON Body Keys
    struct JSONBodyKeys {
        
        static let UserName = "username"
        static let Password = "password"
        static let Favorite = "favorite"
        static let Watchlist = "watchlist"
        
    }
    
    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: General
        static let StatusMessage = "status_message"
        static let StatusCode = "status_code"
        
        // MARK: Authorization
        static let RequestToken = "request_token"
        static let SessionID = "id"
        
        // MARK: Account
        static let UserID = "key"
        
       
    }
}