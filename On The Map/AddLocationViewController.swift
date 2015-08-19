//
//  AddLocationViewController.swift
//  On The Map
//
//  Created by Greg Palen on 8/18/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//

import Foundation
import UIKit

class AddLocationViewController: UIViewController {

    @IBAction func doCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}