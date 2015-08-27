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

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var webView: UIWebView!
    
    var completionHandler : ((success: Bool, errorString: String?) -> Void)? = nil
    var appDelegate: AppDelegate!
    var user: UdacityUser?
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    /* Based on student comments, this was added to help with smaller resolution devices */
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        /* Configure the UI */
        self.configureUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.addKeyboardDismissRecognizer()
        self.subscribeToKeyboardNotifications()
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.removeKeyboardDismissRecognizer()
        self.unsubscribeToKeyboardNotifications()
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
    
    
    func cancelAuth() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doLogin() {
        var debugMessage = String("")
        
        let regex = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+[.]{1}[A-Z]{2,4}$"
        // Attribution for above RegEx: http://www.regular-expressions.info/email.html
        
        if usernameTextField.text.isEmpty {
            debugMessage = debugMessage.stringByAppendingString("Please enter a username (email).\n")
        } else if usernameTextField.text.uppercaseString.rangeOfString(regex, options: NSStringCompareOptions.RegularExpressionSearch) == nil {
            debugMessage = debugMessage.stringByAppendingString("Invalid email address provided.\n")
        }
        
        if passwordTextField.text.isEmpty {
            debugMessage = debugMessage.stringByAppendingString("Please enter a password.")
        }
        
        if debugMessage.isEmpty {
            getRequestToken()
        } else {
            showAlert("Please correct the following input errors:", message: debugMessage)
        }
    }
    
    func getRequestToken() {
        UdacityClient.doLogin(usernameTextField.text, password: passwordTextField.text) { (result, error) in
            if error == nil {
                dispatch_async(dispatch_get_main_queue(), { () in
                    self.completeLogin()
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), { () in
                    self.showAlert("LOGIN FAILED",
                        message: "Login attempt was unsuccessful: \n" +
                        "\((error!.userInfo?[NSURLErrorKey]) as! String)")
                })
            }
        }
    }
    
    
    func completeLogin() {
        // prepare to segue to the list of locations
        let nextController = self.storyboard!.instantiateViewControllerWithIdentifier("TabViewController") as! UITabBarController
        self.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        self.presentViewController(nextController, animated: true, completion: nil)
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
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification) / 2
            self.view.superview?.frame.origin.y -= lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if keyboardAdjusted == true {
            self.view.superview?.frame.origin.y += lastKeyboardOffset
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
}