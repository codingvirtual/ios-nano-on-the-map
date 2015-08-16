//
//  StudentLocation.swift
//  On The Map
//
//  Created by Greg Palen on 8/6/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//

import Foundation
import Parse

class StudentLocation: PFObject, PFSubclassing {
    
    @NSManaged var uniqueKey: String?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var mapString: String?
    @NSManaged var mediaURL: String?
    @NSManaged var latitude: String?
    @NSManaged var longitude: String?

    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "StudentLocation"
    }
}
