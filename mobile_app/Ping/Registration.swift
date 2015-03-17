//
//  Registration.swift
//  Ping
//
//  Created by Noah Krim on 2/14/15.
//  Copyright (c) 2015 Ping. All rights reserved.
//

import Foundation
import UIKit

class Registration: UIViewController, NSURLConnectionDataDelegate    {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordreentryField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    var data:NSMutableData? = nil
    var user = User()
    var delegate:UIViewController? = nil
    var response:NSHTTPURLResponse? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.text = ""
        submitButton.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
        cancelButton.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
    }
    
    func pressed(sender: UIButton!)  {
        if(sender == submitButton)  {
            if nameField.text == nil || nameField.text == "" {
                errorLabel.text = "Please enter a name"
            }
            else if passwordField.text == nil || passwordField.text.utf16Count < 6   {
                errorLabel.text = "Password must have at least 6 characters"
            }
            else if passwordreentryField.text == nil || passwordreentryField.text != passwordField.text {
                errorLabel.text = "Passwords must match"
            }
            else if emailField.text == nil || emailField.text.rangeOfString("@") == nil && emailField.text.rangeOfString(".") == nil    {
                errorLabel.text = "Please enter a valid email"
            }
            else if ageField.text == nil || ageField.text == "" || ageField.text.toInt() <= 0   {
                errorLabel.text = "Please enter a valid age"
            }
            else    {
                errorLabel.text = ""
                activityIndicator.startAnimating()
                let url = NSURL(string: "http://www.igotpinged.com/mobile/api/v0.1/users".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
                var request = NSMutableURLRequest(URL: url!)
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                //TO ENCRYPT PASSWORD
                var dict:[NSString:NSObject] = Dictionary()
                dict["name"] = nameField.text as NSString
                dict["email"] = emailField.text as NSString
                dict["age"] = NSNumber(integer: ageField.text.toInt()!)
                dict["password"] = passwordField.text as NSString
                request.HTTPMethod = "POST"
                request.HTTPBody = NSJSONSerialization.dataWithJSONObject(NSDictionary(dictionary: dict), options: nil, error: nil)
                var connection = NSURLConnection(request: request, delegate: self, startImmediately: true)
            }
        }
        else if(sender == cancelButton) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func valueChanged(sender: UITextField!) {
        
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
        if self.data != nil  {
            activityIndicator.stopAnimating()
            if response?.statusCode == 400  {
                var dict = parseJSON(self.data!)
                var alert = UIAlertController(title: "Registration Failed", message: dict.valueForKey("message") as? String, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            var dict = parseJSON(self.data!)
            let token:String = dict.valueForKey("token") as String
            let user_id:Int = (dict.valueForKey("user_id") as NSNumber).integerValue
            user = User(name: nameField.text, user_id: user_id, token: token, age: ageField.text.toInt()!, email: emailField.text)
            (delegate as? Login)?.user = user
            self.dismissViewControllerAnimated(true, completion: nil)
            self.data = nil
        }
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        NSLog("\((response as? NSHTTPURLResponse)!.statusCode)")
        self.response = response as? NSHTTPURLResponse
        if (response as? NSHTTPURLResponse)?.statusCode == 400  {
            //activityIndicator.stopAnimating()
            //var alert = UIAlertController(title: "Registration Failed", message: "Invalid input in registration", preferredStyle: UIAlertControllerStyle.Alert)
            //alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Cancel, handler: nil))
            //self.presentViewController(alert, animated: true, completion: nil)
            self.data = NSMutableData()
        }
        else if (response as? NSHTTPURLResponse)?.statusCode == 201 {
            self.data = NSMutableData()
        }
        else    {
            activityIndicator.stopAnimating()
            var alert = UIAlertController(title: "Error", message: "Error registering", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}