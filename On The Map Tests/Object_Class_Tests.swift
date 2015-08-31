//
//  Object_Class_Tests.swift
//  On The Map
//
//  Created by Greg Palen on 8/5/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//

import UIKit
import XCTest

class Object_Class_Tests: XCTestCase {
	
	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testCreateUdacityUser() {
		// This is an example of a functional test case.
		var user = UdacityUser(userId: 37)
		XCTAssert(user.userId > 0, "Pass")
	}
	
}
