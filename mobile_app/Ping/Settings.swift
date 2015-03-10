//
//  Setup.swift
//  Ping
//
//  Created by Noah Krim on 3/9/15.
//  Copyright (c) 2015 Ping. All rights reserved.
//

import Foundation
import UIKit

class Settings: UIViewController, NSURLConnectionDataDelegate   {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordreentryLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordreentryField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var submitButton: UIButton!
    
    var user = User()
    var data = NSMutableData()
    var delegate:UIViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.setToolbarHidden(true, animated: true)
        
        submitButton.enabled = false
        submitButton.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
        nameField.addTarget(self, action: "valueChanged:", forControlEvents: .EditingChanged)
        passwordField.addTarget(self, action: "valueChanged:", forControlEvents: .EditingChanged)
        passwordreentryField.addTarget(self, action: "valueChanged:", forControlEvents: .EditingChanged)
        emailField.addTarget(self, action: "valueChanged:", forControlEvents: .EditingChanged)
        ageField.addTarget(self, action: "valueChanged:", forControlEvents: .EditingChanged)
    }
    
    func valueChanged(sender: UITextField) {
        if sender == nameField && nameField.text != "" {
            nameLabel.textColor = UIColor.darkGrayColor()
        }
        else    {
            nameLabel.textColor = UIColor.lightGrayColor()
        }
        if sender == passwordField && passwordField.text != "" {
            passwordLabel.textColor = UIColor.darkGrayColor()
            if passwordField.text == passwordreentryField.text  {
                passwordreentryLabel.textColor = UIColor.darkGrayColor()
            }
            else    {
                passwordreentryLabel.textColor = UIColor.lightGrayColor()
            }
        }
        else    {
            passwordLabel.textColor = UIColor.lightGrayColor()
        }
        if sender == passwordreentryField && passwordreentryField.text != "" && passwordreentryField.text == passwordField.text {
            passwordreentryLabel.textColor = UIColor.darkGrayColor()
        }
        else    {
            passwordreentryLabel.textColor = UIColor.lightGrayColor()
        }
        if sender == emailField && emailField.text != "" {
            emailLabel.textColor = UIColor.darkGrayColor()
        }
        else    {
            emailLabel.textColor = UIColor.lightGrayColor()
        }
        if sender == ageField && ageField.text != "" {
            ageLabel.textColor = UIColor.darkGrayColor()
        }
        else    {
            ageLabel.textColor = UIColor.lightGrayColor()
        }
        if nameField.text != "" || emailField.text != "" || ageField.text != "" || (passwordField.text != "" && passwordField.text == passwordreentryField.text)    {
            submitButton.enabled = true
        }
        else    {
            submitButton.enabled = false
        }
    }
    
    func pressed(sender: UIButton)  {
        activityIndicator.startAnimating()
        let url = NSURL(string: "http://localhost:5000/mobile/api/v0.1/users".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        var request = NSMutableURLRequest(URL: url!)
        //TO ENCRYPT PASSWORD
        let name = (nameField.text != "" ? nameField.text : user.name)
        let email = (emailField.text != "" ? emailField.text : user.email)
        let age = (ageField.text != "" ? ageField.text : String(user.age))
        var bodyData = "name=\(name)&email=\(email)&age=\(age)" + (passwordField.text != "" ? "&password=\(passwordField.text)" : "")
        request.HTTPMethod = "PUT"
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
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
        activityIndicator.stopAnimating()
        var dict = parseJSON(self.data)
        let token:String = dict.objectForKey("token") as String
        user.token = token
        (delegate as? Map)?.user = user
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        if (response as? NSHTTPURLResponse)?.statusCode == 400  {
            activityIndicator.stopAnimating()
            var alert = UIAlertController(title: "Failed Register", message: "Registration failed", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else if (response as? NSHTTPURLResponse)?.statusCode == 200 {
            self.data = NSMutableData()
        }
        else    {
            activityIndicator.stopAnimating()
            var alert = UIAlertController(title: "Error", message: "Error", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}
