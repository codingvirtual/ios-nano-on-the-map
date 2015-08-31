//
//  AppConfiguration.swift
//  On The Map
//
//  Created by Greg Palen on 8/31/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//

import Foundation

public class AppConfiguration {
	
	var user: UdacityUser?
	
	public class var sharedConfiguration: AppConfiguration {
		struct Singleton {
			static let sharedAppConfiguration = AppConfiguration()
		}
		
		return Singleton.sharedAppConfiguration
	}
}