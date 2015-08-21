//
//  LoginViewController.swift
//  On The Map
//
//  Created by Greg Palen on 8/2/15.
//  Copyright (c) 2015 codingvirtual. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var webView: UIWebView!
        
    var urlRequest: NSURLRequest? = nil
    var requestToken: String? = nil
    var completionHandler : ((success: Bool, errorString: String?) -> Void)? = nil
    var appDelegate: AppDelegate!
    var user: UdacityUser?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // webView.delegate = self
        
        // self.navigationItem.title = "Udacity Login"
        // self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelAuth")
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate

        if urlRequest != nil {
            self.webView.loadRequest(urlRequest!)
        }
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
        UdacityClient.doLogin(email.text, password: password.text) { (result, error) in
            if error == nil {
                // prepare to segue to the list of locations (pass the UdacityUser)
                dispatch_async(dispatch_get_main_queue(), { () in
                let nextController = self.storyboard!.instantiateViewControllerWithIdentifier("TabViewController") as! UITabBarController
                self.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
                self.presentViewController(nextController, animated: true, completion: nil)
                })
            }
            if error != nil {
                println("there was an error: \(error)")
            }
            return
        }
    }
}