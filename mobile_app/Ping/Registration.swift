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
    
    //PASSWROD
    //6
    //CHARACTERS
    //REMEMBER!!!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordreentryField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var data = NSMutableData()
    var user = User()
    var delegate:UIViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
        cancelButton.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
    }
    
    func pressed(sender: UIButton!)  {
        if(sender == submitButton)  {
            activityIndicator.startAnimating()
            let url = NSURL(string: "http://localhost:5000/mobile/api/v0.1/users".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
            var request = NSMutableURLRequest(URL: url!)
            //TO ENCRYPT PASSWORD
            var dict = ["name":nameField.text, "email":emailField.text, "age":ageField.text, "password":passwordField.text]
            request.HTTPMethod = "POST"
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(NSDictionary(dictionary: dict), options: nil, error: nil)
            var connection = NSURLConnection(request: request, delegate: self, startImmediately: true)
        }
        else if(sender == cancelButton) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
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
        let token:String = dict.valueForKey("token") as String
        let user_id:String = dict.valueForKey("user_id") as String
        user = User(name: nameField.text, user_id: user_id, token: token, age: ageField.text.toInt()!, email: emailField.text)
        (delegate as? Login)?.user = user
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        if (response as? NSHTTPURLResponse)?.statusCode == 400  {
            activityIndicator.stopAnimating()
            var alert = UIAlertController(title: "Registration Failed", message: "Invalid input in registration", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
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