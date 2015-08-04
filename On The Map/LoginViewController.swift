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
    
    var udacityClient: UdacityClient! = UdacityClient.sharedInstance()
    
    var urlRequest: NSURLRequest? = nil
    var requestToken: String? = nil
    var completionHandler : ((success: Bool, errorString: String?) -> Void)? = nil
    
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
        
        if urlRequest != nil {
            self.webView.loadRequest(urlRequest!)
        }
    }
    
    // MARK: - UIWebViewDelegate
    
    func webViewDidFinishLoad(webView: UIWebView) {
        
        if(webView.request!.URL!.absoluteString! == "\(UdacityClient.Constants.AuthorizationURL)\(requestToken!)/allow") {
            
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                self.completionHandler!(success: true, errorString: nil)
            })
        }
    }
    
    func cancelAuth() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func doLogin() {
        println("email = \(email.text), pass = \(password.text)")
        UdacityClient.doLogin(email.text, password: password.text) { (result, error) in
            if result != nil {
                println("there was a result")
                
                if let sessionDict = result.valueForKey("account") as? [String:AnyObject] {
                    println(sessionDict["key"]!)

                } else {
                    println("Cant find key 'udacity' in \(result)")
                }
                
            }
            if error != nil {println("there was an error")}
            println("done")
            return
        }
    }
}