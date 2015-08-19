//
//  GetLinkViewController.swift
//  On The Map
//
//  Created by Greg Palen on 8/19/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class GetLinkViewController: UIViewController {
    
    var location: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        println("Location received \(location!.description)")
    }
   
}