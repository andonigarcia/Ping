//
//  Login.swift
//  Ping
//
//  Created by Noah Krim on 2/14/15.
//  Copyright (c) 2015 Ping. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Login: UIViewController, NSURLConnectionDataDelegate   {
    
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var newmemberButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    
    var data:NSMutableData? = nil
    var user:User = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        
        errorLabel.text = ""
        submitButton.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        errorLabel.text = ""
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.setToolbarHidden(true, animated: true)
        saveUser(0, token: "")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if sender as? UIButton == submitButton  {
            var dvc:Map = segue.destinationViewController as Map
            dvc.user = user
            dvc.delegate = self
        }
        else if sender as? UIButton == newmemberButton  {
            var dvc:Registration = segue.destinationViewController as Registration
            dvc.delegate = self
        }
    }
    
    func pressed(sender: UIButton!) {
        if emailField.text == nil || emailField.text.rangeOfString("@") == nil && emailField.text.rangeOfString(".") == nil {
            errorLabel.text = "Please enter a valid email"
        }
        else if passwordField.text == nil || passwordField.text.utf16Count < 6   {
            errorLabel.text = "Password must have at least 6 characters"
        }
        else    {
            errorLabel.text = ""
            activityIndicator.startAnimating()
            //HTTP request to login with given username and password
            //SHOULD ENCRYPT PASSWORD FIRST!!!!!!!!
            let url = NSURL(string: "http://www.igotpinged.com/mobile/api/v0.1/token".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
            var request = NSMutableURLRequest(URL: url!)
            request.HTTPMethod = "POST"
            let loginString = "\(emailField.text):\(passwordField.text)"
            let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
            let base64LoginString = loginData.base64EncodedStringWithOptions(nil)
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
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
        if self.data != nil  {
            //If the data is from logging in
            if connection.currentRequest.URL == NSURL(string: "http://www.igotpinged.com/mobile/api/v0.1/token".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)   {
                activityIndicator.stopAnimating()
                var dict = parseJSON(self.data!)
                let token:String = dict.valueForKey("token") as String
                let user_id:Int = (dict.valueForKey("user_id") as NSNumber).integerValue
                user = User(user_id: user_id, token: token)
            
                //HTTP request to get user information
                let url = NSURL(string: "http://www.igotpinged.com/mobile/api/v0.1/users/\(user.user_id)".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
                var request = NSMutableURLRequest(URL: url!)
                let loginString = "\(token):token"
                let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
                let base64LoginString = loginData.base64EncodedStringWithOptions(nil)
                request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
                var connection = NSURLConnection(request: request, delegate: self, startImmediately: true)
            }
            //If the data is from getting the user infomration
            else if connection.currentRequest.URL == NSURL(string: "http://www.igotpinged.com/mobile/api/v0.1/users/\(user.user_id)".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)    {
                var dict = parseJSON(self.data!)
                user.name = dict.valueForKey("username") as String
                user.age = (dict.valueForKey("age") as NSNumber).integerValue
                user.email = dict.valueForKey("email") as String
                saveUser(user.user_id, token: user.token)
                performSegueWithIdentifier("submit", sender: submitButton)
            }
            self.data = nil
        }
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        NSLog("\((response as? NSHTTPURLResponse)!.statusCode)")
        if (response as? NSHTTPURLResponse)?.statusCode == 401  {
            activityIndicator.stopAnimating()
            var alert = UIAlertController(title: "Failed to Login", message: "Invalid Username/Password", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else if (response as? NSHTTPURLResponse)?.statusCode == 200 {
            NSLog("Success")
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

    /*func connection(connection: NSURLConnection, didReceiveAuthenticationChallenge challenge: NSURLAuthenticationChallenge) {
        if connection.currentRequest.URL == NSURL(string: "http://www.igotpinged.com/mobile/api/v0.1/token".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)   {
            if challenge.previousFailureCount == 0  {
                let creds = NSURLCredential(user: emailField.text, password: passwordField.text, persistence: NSURLCredentialPersistence.None)
                challenge.sender.useCredential(creds, forAuthenticationChallenge: challenge)
            }
            else    {
                challenge.sender.continueWithoutCredentialForAuthenticationChallenge(challenge)
            }
        }
        else if connection.currentRequest.URL == NSURL(string: "http://www.igotpinged.com/mobile/api/v0.1/users/\(user.user_id)".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)    {
            if challenge.previousFailureCount == 0  {
                let creds = NSURLCredential(user: user.token, password: "token", persistence: NSURLCredentialPersistence.None)
                challenge.sender.useCredential(creds, forAuthenticationChallenge: challenge)
            }
            else    {
                challenge.sender.continueWithoutCredentialForAuthenticationChallenge(challenge)
            }
        }
    }*/
    
    // CORE DATA FUNCTIONALITY
    
    func saveUser(id: Int, token: String) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName:"User")
        var error: NSError?
        
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        if fetchedResults == nil || fetchedResults?.count == 0  {
            let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: managedContext)
            let user = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
            user.setValue(id, forKey: "id")
            user.setValue(token, forKey: "token")
        }
        else    {
            if let results = fetchedResults {
                let user = results[0]
                user.setValue(id, forKey: "id")
                user.setValue(token, forKey: "token")
            }
        }
        if !managedContext.save(&error) {
            NSLog("Could not save \(error), \(error?.userInfo)")
        }
    }
}
