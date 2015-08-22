//
//  LoginViewController.swift
//  On The Map
//
//  Created by Greg Palen on 8/2/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var webView: UIWebView!
    
    var urlRequest: NSURLRequest? = nil
    var requestToken: String? = nil
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
        // webView.delegate = self
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // self.navigationItem.title = "Udacity Login"
        // self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelAuth")
        /* Configure the UI */
        self.configureUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        /*
        if urlRequest != nil {
        self.webView.loadRequest(urlRequest!)
        }
        */
        
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
    
    
    // MARK: - UIWebViewDelegate
    
    func webViewDidFinishLoad(webView: UIWebView) {
        /*
        if(webView.request!.URL!.absoluteString! == "\(UdacityClient.Constants.AuthorizationURL)\(requestToken!)/allow") {
        
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
        self.completionHandler!(success: true, errorString: nil)
        })
        }
        */
    }
    
    func cancelAuth() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doLogin() {
        var debugMessage = String("")
        if usernameTextField.text.isEmpty {
            debugMessage = debugMessage.stringByAppendingString("Username Empty.\n")
        }
        if passwordTextField.text.isEmpty {
            debugMessage = debugMessage.stringByAppendingString("Password Empty.")
        }
        if debugMessage.isEmpty {
            
            /*
            Steps for Authentication...
            https://www.themoviedb.org/documentation/api/sessions
            
            Step 1: Create a new request token
            Step 2: Ask the user for permission via the API ("login")
            Step 3: Create a session ID
            
            Extra Steps...
            Step 4: Go ahead and get the user id ;)
            Step 5: Got everything we need, go to the next view!
            
            */
            self.getRequestToken()
        } else {
            showAlert("Required fields missing", message: debugMessage)
        }
    }

    func showAlert(title: String?, message: String?) {
        let alertController = UIAlertController()
        if title != nil {alertController.title = title} else {alertController.title = "This alert needs a title!"}
        if message != nil {alertController.message = message} else {alertController.message = "This alert needs a message!"}
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) { action in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    func getRequestToken() {
        UdacityClient.doLogin(usernameTextField.text, password: passwordTextField.text) { (result, error) in
            if error == nil {
                self.completeLogin()
            } else {
                println("there was an error: \(error)")
            }
        }
    }
    

    func completeLogin() {
        // prepare to segue to the list of locations (pass the UdacityUser)
        dispatch_async(dispatch_get_main_queue(), { () in
            let nextController = self.storyboard!.instantiateViewControllerWithIdentifier("TabViewController") as! UITabBarController
                self.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
                self.presentViewController(nextController, animated: true, completion: nil)
        })
    }
}
// MARK: - Helper

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
        
        /* Configure debug text label */
        //        headerTextLabel.font = UIFont(name: "AvenirNext-Medium", size: 20)
        //        headerTextLabel.textColor = UIColor.whiteColor()
        
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