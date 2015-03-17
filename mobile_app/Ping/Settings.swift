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
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordreentryField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var submitButton: UIButton!
    
    var user = User()
    var data:NSMutableData? = nil
    var delegate:UIViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.setToolbarHidden(true, animated: true)
        
        errorLabel.text = ""
        submitButton.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
        nameField.addTarget(self, action: "valueChanged:", forControlEvents: .EditingChanged)
        passwordField.addTarget(self, action: "valueChanged:", forControlEvents: .EditingChanged)
        passwordreentryField.addTarget(self, action: "valueChanged:", forControlEvents: .EditingChanged)
        emailField.addTarget(self, action: "valueChanged:", forControlEvents: .EditingChanged)
        ageField.addTarget(self, action: "valueChanged:", forControlEvents: .EditingChanged)
    }
    
    func valueChanged(sender: UITextField) {
        if nameField.text != "" {
            nameLabel.textColor = UIColor.darkGrayColor()
        }
        else    {
            nameLabel.textColor = UIColor.lightGrayColor()
        }
        if passwordField.text != "" {
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
        if passwordreentryField.text != "" && passwordreentryField.text == passwordField.text {
            passwordreentryLabel.textColor = UIColor.darkGrayColor()
        }
        else    {
            passwordreentryLabel.textColor = UIColor.lightGrayColor()
        }
        if emailField.text != "" {
            emailLabel.textColor = UIColor.darkGrayColor()
        }
        else    {
            emailLabel.textColor = UIColor.lightGrayColor()
        }
        if ageField.text != "" {
            ageLabel.textColor = UIColor.darkGrayColor()
        }
        else    {
            ageLabel.textColor = UIColor.lightGrayColor()
        }
    }
    
    func pressed(sender: UIButton)  {
        if passwordField.text != nil && passwordField.text != "" && passwordField.text.utf16Count < 6   {
            errorLabel.text = "Password must have at least 6 characters"
        }
        else if passwordreentryField.text != nil && passwordreentryField.text != passwordField.text {
            errorLabel.text = "Passwords must match"
        }
        else if emailField.text != nil && emailField.text != "" && (emailField.text.rangeOfString("@") == nil || emailField.text.rangeOfString(".") == nil)    {
            errorLabel.text = "Please enter a valid email"
        }
        else    {
            errorLabel.text = ""
            activityIndicator.startAnimating()
            let url = NSURL(string: "http://www.igotpinged.com/mobile/api/v0.1/users/\(user.user_id)".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
            var request = NSMutableURLRequest(URL: url!)
            let loginString = "\(user.token):token"
            let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
            let base64LoginString = loginData.base64EncodedStringWithOptions(nil)
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
            //TO ENCRYPT PASSWORD
            //SET BODYDATA TO JSON FROM NSDICTIONARY
            let name = (nameField.text != "" ? nameField.text : user.name)
            let email = (emailField.text != "" ? emailField.text : user.email)
            var age:NSNumber
            if ageField.text != ""{
                age = NSNumber(integer: ageField.text.toInt()!)
            }
            else    {
                age = NSNumber(integer: user.age)
            }
            var dict:[NSString:NSObject] = Dictionary()
            dict["name"] = name
            dict["email"] = email
            dict["age"] = age
            if passwordField.text != "" {
                dict["password"] = passwordField.text
            }
            var bodyData = NSDictionary(dictionary: dict)
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.HTTPMethod = "PUT"
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(bodyData, options: nil, error: nil)
            var connection = NSURLConnection(request: request, delegate: self, startImmediately: true)
        }
    }
    
    //INTERNET FUNCTIONALITIES
    
    func parseJSON(inputData: NSData) -> NSDictionary{
        var error: NSError?
        var dict: NSDictionary = NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
        
        return dict
    }
    
    func connection(connection: NSURLConnection!, didReceiveData _data: NSData!)    {
        self.data?.appendData(_data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!)   {
        if data != nil  {
            activityIndicator.stopAnimating()
            var dict = parseJSON(self.data!)
            let token:String = dict.valueForKey("token") as String
            user.token = token
            (delegate as? Map)?.user = user
            self.navigationController?.popViewControllerAnimated(true)
            self.data = nil
        }
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        NSLog("\((response as? NSHTTPURLResponse)!.statusCode)")
        if (response as? NSHTTPURLResponse)?.statusCode == 400  {
            activityIndicator.stopAnimating()
            var alert = UIAlertController(title: "Invalid Settings", message: "Input for settings invalid", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else if (response as? NSHTTPURLResponse)?.statusCode == 200 {
            self.data = NSMutableData()
        }
        else if (response as? NSHTTPURLResponse)?.statusCode == 403  {
            activityIndicator.stopAnimating()
            var alert = UIAlertController(title: "Invalid Auth Token", message: "There was an authentication error on the server", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else    {
            activityIndicator.stopAnimating()
            var alert = UIAlertController(title: "Error", message: "Error updating settings", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    /*func connection(connection: NSURLConnection, didReceiveAuthenticationChallenge challenge: NSURLAuthenticationChallenge) {
        NSLog("didReceiveAuthChallenge")
        if challenge.previousFailureCount == 0  {
            let creds = NSURLCredential(user: user.token, password: "token", persistence: NSURLCredentialPersistence.None)
            challenge.sender.useCredential(creds, forAuthenticationChallenge: challenge)
        }
        else    {
            challenge.sender.continueWithoutCredentialForAuthenticationChallenge(challenge)
        }
    }*/
}
