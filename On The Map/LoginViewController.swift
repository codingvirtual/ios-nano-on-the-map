//
//  LoginViewController.swift
//  On The Map
//
//  Created by Greg Palen on 8/2/15.
//  Copyright (c) 2015 Greg Palen except as noted below.
//

//  Attribution: portions of the following code adapted from "MyFavoriteMovies" app. License info copied below.
//  Code used in this case for educational use under Fair Use rules of copyright.
//  Original code created by Jarrod Parkes on 1/23/15.
//  Copyright (c) 2015 Udacity. All rights reserved.

//  Note that UIViewController is extended by UIViewControllerExtension.swift which contains
//  the code to raise an AlertView by any of the view controllers in this application.

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
	
	// Outlets for the username and password fields on the login screen
	@IBOutlet weak var usernameTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	
	// Get a reference to the app delegate to enable access to the user property
	let appDelegate: AppDelegate! = UIApplication.sharedApplication().delegate as! AppDelegate
	// the UdacityUser that is represented by the login creds
	var user = AppConfiguration.sharedConfiguration.user
	var tapRecognizer: UITapGestureRecognizer? = nil
	
	/* Based on student comments, this was added to help with smaller resolution devices */
	var keyboardAdjusted = false
	var lastKeyboardOffset : CGFloat = 0.0
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		/* Configure the UI */
		self.configureUI()
	}
	
	// Override default functionality to enable keyboard-related functionality
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.addKeyboardDismissRecognizer()
		self.subscribeToKeyboardNotifications()
	}

	// Override default functionality to disable keyboard-related functionality
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		self.removeKeyboardDismissRecognizer()
		self.unsubscribeToKeyboardNotifications()
	}

	// Function called when the user taps the Login button on the view.
	// This function does some basic input validation and then attempts
	// to log the user in using the provided credentials.
	@IBAction func doLogin() {
		self.resignFirstResponder()
		var debugMessage = String("")	// will contain all debug messages after all validation
		
		// First, validate that a proper username was entered. In this case, proper equates
		// to an email address. Use a regular expression to validate the entered data.
		let regex = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+[.]{1}[A-Z]{2,4}$"
		// Attribution for above RegEx: http://www.regular-expressions.info/email.html
		
		// Now validate the username. Check that it's not empty and also check to ensure
		// it conforms to the general format of an email address as "described" by the
		// above regex
		// If a validation check fails, append an appropriate message to the debugMessage
		// variable which will later be used by an AlertView to help the user understand
		// what they need to correct.
		if usernameTextField.text.isEmpty {
			debugMessage = debugMessage.stringByAppendingString("Please enter a username (email).\n")
		} else if usernameTextField.text.uppercaseString.rangeOfString(regex, options: NSStringCompareOptions.RegularExpressionSearch) == nil {
			debugMessage = debugMessage.stringByAppendingString("Invalid email address provided.\n")
		}
		
		// Now check the password field. In this case, simply check that it's not empty.
		// NOTE: more thorough checking could be done with a proper regular expression 
		// that describes the form of a valid password. Length could also be checked to
		// ensure the data entered conforms to the password length requirements.
		if passwordTextField.text.isEmpty {
			debugMessage = debugMessage.stringByAppendingString("Please enter a password.")
		}
		
		// All validation has been completed. Inspect debugMessage as an indicator of the success
		// of validation. If it's empty, then all validation succeeded, so process the login
		// request.
		if debugMessage.isEmpty {
			handleLogin()
		} else {
			// If debugMessage was NOT empty, show an AlertView containing the validation
			// error message(s)
			showAlert("Please correct the following input errors:", message: debugMessage)
		}
	}
	
	// this function takes the username and password entered it the fields and calls the
	// appropriate method in the UdacityClientOperations class to request a login.
	// The completion handler either calls completeLogin if the login was successful (which
	// will do a modal seque to the tabbed locations view) or raise an AlertView that
	// contains error information if the login failed.
	func handleLogin() {
		UdacityClientOperations.doLogin(usernameTextField.text, password: passwordTextField.text) { (result, error) in
			if error == nil {
				// No errors occurred, so complete login.
				dispatch_async(dispatch_get_main_queue(), { () in
					self.completeLogin()
				})
			} else {
				// An error occurred, so raise an AlertMessage
				dispatch_async(dispatch_get_main_queue(), { () in
					self.showAlert("LOGIN FAILED",
						message: "Login attempt was unsuccessful: \n" +
						"\((error!.userInfo?[NSURLErrorKey]) as! String)")
				})
			}
		}
	}
	
	// Function that segues to the tabbed locations list.
	private func completeLogin() {
		// prepare to segue to the list of locations
		let nextController = self.storyboard!.instantiateViewControllerWithIdentifier("TabViewController") as! UITabBarController
		self.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
		self.presentViewController(nextController, animated: true, completion: nil)
	}
	
	// Function that is triggered when the user clicks the Sign Up link/words below the login area. Causes Safari to open
	// and load the Udacity sign-up page.
	@IBAction func showSignUp() {
		UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
	}
	
	// MARK: - Keyboard Fixes
	
	func addKeyboardDismissRecognizer() {
		self.view.addGestureRecognizer(tapRecognizer!)
	}
	
	func removeKeyboardDismissRecognizer() {
		self.view.removeGestureRecognizer(tapRecognizer!)
	}
	
	func handleSingleTap(recognizer: UITapGestureRecognizer) {
		self.view.endEditing(true)
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true;
	}
	
	func textFieldShouldEndEditing(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}

// MARK: - Helper

//  Attribution: all of the following code extracted from "MyFavoriteMovies" app. License info copied below.
//  Code used in this case for educational reasons under Fair Use.
//  Created by Jarrod Parkes on 1/23/15.
//  Copyright (c) 2015 Udacity. All rights reserved.

extension LoginViewController {
	
	func configureUI() {
		
		/* Configure email textfield */
		usernameTextField.font = UIFont(name: "AvenirNext-Medium", size: 17.0)
		usernameTextField.backgroundColor = UIColor(red: 0.702, green: 0.863, blue: 0.929, alpha:1.0)
		usernameTextField.textColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
		usernameTextField.attributedPlaceholder = NSAttributedString(string: usernameTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
		usernameTextField.tintColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
		
		/* Configure password textfield */
		passwordTextField.font = UIFont(name: "AvenirNext-Medium", size: 17.0)
		passwordTextField.backgroundColor = UIColor(red: 0.702, green: 0.863, blue: 0.929, alpha:1.0)
		passwordTextField.textColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
		passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
		passwordTextField.tintColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
		
		/* Configure tap recognizer */
		tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
		tapRecognizer?.numberOfTapsRequired = 1
		
	}
}

extension LoginViewController {
	
	// sets up this ViewController to be notified when the keyboard shows or hides
	func subscribeToKeyboardNotifications() {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
	}
	
	// Removes notifications of the keyboard hiding or showing
	func unsubscribeToKeyboardNotifications() {
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
	}
	
	// Called when the keyboard will show. Causes the view to slide up by an amount equal to the keyboard height
	func keyboardWillShow(notification: NSNotification) {
		
		if keyboardAdjusted == false {
			// Save the current offset
			lastKeyboardOffset = getKeyboardHeight(notification) / 2
			self.view.superview?.frame.origin.y -= lastKeyboardOffset
			keyboardAdjusted = true
		}
	}
	
	// Called when the keyboard is going to hide. Causes the view to go back to the way it was before the keyboard appeared
	func keyboardWillHide(notification: NSNotification) {
		
		if keyboardAdjusted == true {
			self.view.superview?.frame.origin.y += lastKeyboardOffset
			keyboardAdjusted = false
		}
	}
	
	// Calculates and returns the height of the keyboard which is used as an offset to adjust the y-value of the view.
	func getKeyboardHeight(notification: NSNotification) -> CGFloat {
		let userInfo = notification.userInfo
		let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
		return keyboardSize.CGRectValue().height
	}
}