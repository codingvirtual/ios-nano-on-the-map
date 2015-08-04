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
        static let AuthorizationURL : String = "https://www.udacity.com/api/session"
        
    }
    
    // MARK: - Methods
    struct Methods {
        
        // MARK: Account
        static let Account = "account"
        
        // MARK: Authentication
        static let AuthenticationTokenNew = "authentication/token/new"
        static let AuthenticationSessionNew = "authentication/session/new"

    }
    
    // MARK: - URL Keys
    struct URLKeys {
        
        static let UserID = "id"
        
    }
    
    // MARK: - Parameter Keys
    struct ParameterKeys {
        
        static let SessionID = "session_id"
        static let RequestToken = "request_token"
        
    }
    
    // MARK: - JSON Body Keys
    struct JSONBodyKeys {
        
        static let MediaType = "media_type"
        static let MediaID = "media_id"
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
        static let SessionID = "session_id"
        
        // MARK: Account
        static let UserID = "id"
        
       
    }
}