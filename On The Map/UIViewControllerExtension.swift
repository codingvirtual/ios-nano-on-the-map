//
//  UIViewControllerExtension.swift
//  On The Map
//
//  Created by Greg Palen on 8/25/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//

import UIKit

extension UIViewController {
	
	func showAlert(title: String?, message: String?) {
		let alertController = UIAlertController()
		if title != nil {alertController.title = title!} else {alertController.title = "This alert needs a title!"}
		if message != nil {alertController.message = message!} else {alertController.message = "This alert needs a message!"}
		
		let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { action in
			alertController.dismissViewControllerAnimated(true, completion: nil)
		}
		alertController.addAction(okAction)
		self.presentViewController(alertController, animated: true, completion: nil)
	}
	
	func showAlert(title: String?, message: String?, withDismissalHandler: (() -> Void)?) {
		let alertController = UIAlertController()
		if title != nil {alertController.title = title} else {alertController.title = "This alert needs a title!"}
		if message != nil {alertController.message = message} else {alertController.message = "This alert needs a message!"}
		
		let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.Default) { action in
			if withDismissalHandler != nil {
				withDismissalHandler!()
			} else {
				alertController.dismissViewControllerAnimated(true, completion: nil)
			}
		}
		alertController.addAction(okAction)
		self.presentViewController(alertController, animated: true, completion: nil)
	}
	
}