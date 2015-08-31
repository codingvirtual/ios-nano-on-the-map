//
//  UIViewControllerExtension.swift
//  On The Map
//
//  Created by Greg Palen on 8/25/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//

// This code extends the UIViewController "superclass" to create a standardized but
// configurable AlertView. Two versions are provided:
// A basic version that simply shows the alert (and allows for configuration in the call
// parameters) and
// An enhanced version that allows the caller to provide a dismissalHandler that is
// invoked when the AlertView is dismissed by the user. The enhanced version is handy
// for allowing the dismissal to trigger further activities such as presenting a different
// ViewController, etc.

import UIKit

extension UIViewController {
	
	// Basic version. Caller provides a title and a message that is used to configure
	// the AlertView. This Basic version has an "OK" button that simply dismisses the
	// AlertView without any further action.
	func showAlert(title: String?, message: String?) {
		let alertController = UIAlertController()
		// If by chance no title or message was provided, create a default value to show.
		if title != nil {alertController.title = title!} else {alertController.title = "This alert needs a title!"}
		if message != nil {alertController.message = message!} else {alertController.message = "This alert needs a message!"}
		// Create the OK button that will dismiss the AlertView
		let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { action in
			alertController.dismissViewControllerAnimated(true, completion: nil)
		}
		alertController.addAction(okAction)
		// Show the AlertView
		self.presentViewController(alertController, animated: true, completion: nil)
	}
	
	// Enhanced version. Works just as the above version, but allows the caller to provide
	// a dismissalHandler that is invoked when the user taps the OK button to dismiss the
	// alert.
	func showAlert(title: String?, message: String?, withDismissalHandler: (() -> Void)?) {
		let alertController = UIAlertController()
		if title != nil {alertController.title = title} else {alertController.title = "This alert needs a title!"}
		if message != nil {alertController.message = message} else {alertController.message = "This alert needs a message!"}
		
		// If a dismissalHandler was provided, set up the action button to invoke it when tapped
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