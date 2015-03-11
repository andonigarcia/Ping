//
//  Login.swift
//  Ping
//
//  Created by Noah Krim on 2/14/15.
//  Copyright (c) 2015 Ping. All rights reserved.
//

import Foundation
import UIKit

class Login: UIViewController, NSURLConnectionDataDelegate   {
    
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var newmemberButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var data:NSMutableData = NSMutableData()
    var user:User = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        
        submitButton.enabled = false
        submitButton.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
        emailField.addTarget(self, action: "valueChanged:", forControlEvents: .EditingChanged)
        passwordField.addTarget(self, action: "valueChanged:", forControlEvents: .EditingChanged)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.setToolbarHidden(true, animated: true)
        if user.name != "" {
            emailField.text = user.name
            passwordField.text = ""
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if sender as? UIButton == submitButton  {
            var dvc:Map = segue.destinationViewController as Map
            dvc.user = user
        }
        else if sender as? UIButton == newmemberButton  {
            var dvc:Registration = segue.destinationViewController as Registration
            dvc.delegate = self
        }
    }
    
    func valueChanged(sender: UITextField!)   {
        if emailField.text != nil && emailField.text != "" && passwordField.text != nil && passwordField.text != ""   {
            submitButton.enabled = true
        }
        else    {
            submitButton.enabled = false
        }
    }
    
    func pressed(sender: UIButton!) {
        activityIndicator.startAnimating()
        //HTTP request to login with given username and password
        //SHOULD ENCRYPT PASSWORD FIRST!!!!!!!!
        let url = NSURL(string: "http://localhost:5000/mobile/api/v0.1/token".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        var request = NSMutableURLRequest(URL: url!)
        request.setValue("Basic \(emailField.text):\(passwordField.text)", forHTTPHeaderField: "Authorization")
        var connection = NSURLConnection(request: request, delegate: self, startImmediately: true)
    }
    
    //INTERNET FUNCTIONALITIES
    
    func parseJSON(inputData: NSData) -> NSDictionary{
        var error: NSError?
        var dict: NSDictionary = NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
        
        return dict
    }
    
    func connection(connection: NSURLConnection!, didReceiveData _data: NSData!)    {
        self.data.appendData(_data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!)   {
        //If the data is from logging in
        if connection.currentRequest.URL == NSURL(string: "http://localhost:5000/mobile/api/v0.1/token".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)   {
            activityIndicator.stopAnimating()
            var dict = parseJSON(self.data)
            let token:String = dict.valueForKey("token") as String
            let user_id:String = dict.valueForKey("user_id") as String
            user = User(user_id: user_id, token: token)
            
            //HTTP request to get user information
            let url = NSURL(string: "http://localhost:5000/mobile/api/v0.1/users/\(user.user_id)".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
            var request = NSMutableURLRequest(URL: url!)
            request.setValue("Basic \(user.token):token", forHTTPHeaderField: "Authorization")
            var connection = NSURLConnection(request: request, delegate: self, startImmediately: true)
        }
        //If the data is from getting the user infomration
        else if connection.currentRequest.URL == NSURL(string: "http://localhost:5000/mobile/api/v0.1/users/\(user.user_id)".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)    {
            var dict = parseJSON(self.data)
            user.name = dict.valueForKey("username") as String
            user.age = (dict.valueForKey("age") as String).toInt()!
            user.email = dict.valueForKey("email") as String
            performSegueWithIdentifier("submit", sender: submitButton)
        }
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        if (response as? NSHTTPURLResponse)?.statusCode == 400  {
            activityIndicator.stopAnimating()
            var alert = UIAlertController(title: "Failed to Login", message: "Invalid Username/Password", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else if (response as? NSHTTPURLResponse)?.statusCode == 200 {
            self.data = NSMutableData()
        }
        else if (response as? NSHTTPURLResponse)?.statusCode == 403 {
            activityIndicator.stopAnimating()
            var alert = UIAlertController(title: "Invalid Login Token", message: "There was an error getting user information", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else    {
            activityIndicator.stopAnimating()
            var alert = UIAlertController(title: "Error", message: "Error loging in", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}
