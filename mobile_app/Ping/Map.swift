//
//  Map.swift
//  Ping
//
//  Created by Noah Krim on 2/14/15.
//  Copyright (c) 2015 Ping. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class Map: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, NSURLConnectionDataDelegate  {
    
    var username: NSString = ""
    var locationManager: CLLocationManager!
    var firstUpdate = false
    var user:User = User()
    var data:NSMutableData? = nil
    var delegate:UIViewController? = nil
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.setToolbarHidden(false, animated: true)
        
        logoutButton.target = self
        logoutButton.action = "pressed:"
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.activityType = .Other
        
        if(CLLocationManager.authorizationStatus() != .AuthorizedAlways)  {
            locationManager.requestAlwaysAuthorization()
        }
        if(CLLocationManager.locationServicesEnabled() == true) {
            let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(0.01 , 0.01)
            if locationManager.location != nil {
                let theRegion:MKCoordinateRegion = MKCoordinateRegionMake(locationManager.location.coordinate, theSpan)
                mapView.setRegion(theRegion, animated: true)
            }
        }
        //Load Stores
        if locationManager.location != nil{
            NSLog("Looking for pings")
            //HTTP request to get map information
            let url = NSURL(string: "http://www.igotpinged.com/mobile/api/v0.1/users/\(user.user_id)/map?lat=\(locationManager.location.coordinate.latitude)&lng=\(locationManager.location.coordinate.longitude)".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
            var request = NSMutableURLRequest(URL: url!)
            NSLog(NSString(contentsOfURL: url!, encoding: NSUTF8StringEncoding, error: nil)!)
            let loginString = "\(user.token):token"
            let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
            let base64LoginString = loginData.base64EncodedStringWithOptions(nil)
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
            /*request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.HTTPMethod = "PUT"
            //Dictionary to be converted to JSON
            var dict:[NSString:NSDictionary] = Dictionary()
            var latlong:[NSString:NSNumber] = Dictionary()
            latlong["lat"] = locationManager.location.coordinate.latitude
            latlong["lng"] = locationManager.location.coordinate.longitude
            dict["location"] = NSDictionary(dictionary: latlong)
            //NSLog(NSString(data: NSJSONSerialization.dataWithJSONObject(NSDictionary(dictionary: dict), options: nil, error: nil)!, encoding: NSUTF8StringEncoding)!)
            let json = NSJSONSerialization.dataWithJSONObject(NSDictionary(dictionary: dict), options: nil, error: nil)
            request.HTTPBody = json
            request.setValue(String(json!.length), forHTTPHeaderField: "Content-Length")
            NSLog(NSString(data: request.HTTPBody!, encoding: NSUTF8StringEncoding)!)*/
            var connection = NSURLConnection(request: request, delegate: self, startImmediately: true)
            
        }
    }
    
    func pressed(sender: AnyObject) {
        (self.delegate as Login).user = User()
        (self.delegate as Login).emailField.text = ""
        self.locationManager.stopUpdatingLocation()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(sender as? StoreAnnotation != nil)  {
            var dvc: StoreView = segue.destinationViewController as StoreView
            dvc.annotation = sender as StoreAnnotation
            dvc.user = user
            dvc.locationManager = self.locationManager
        }
        else if(sender as? UIBarButtonItem == settingsButton)   {
            var dvc:Settings = segue.destinationViewController as Settings
            dvc.delegate = self
            dvc.user = user
        }
    }
    
    //MAP FUNCTIONALITIES
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        //NSLog("Did update location")
        let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(0.01 , 0.01)
        let theRegion:MKCoordinateRegion = MKCoordinateRegionMake(locationManager.location.coordinate, theSpan)
        mapView.setRegion(theRegion, animated: true)
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!)    {
        let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(0.01 , 0.01)
        let theRegion:MKCoordinateRegion = MKCoordinateRegionMake(locationManager.location.coordinate, theSpan)
        mapView.setRegion(theRegion, animated: true)
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if(annotation is MKUserLocation)    {
            return nil
        }
        
        let reuseId = "storePin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if(pinView == nil){
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView!.pinColor = .Red
            
            var calloutButton = UIButton.buttonWithType(.DetailDisclosure) as UIButton
            pinView!.rightCalloutAccessoryView = calloutButton
        } else {
            pinView!.annotation = annotation
        }
        return pinView!
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if(control == view.rightCalloutAccessoryView) {
            performSegueWithIdentifier("toStore", sender: view.annotation)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if(status == .AuthorizedAlways)   {
            NSLog("Started updating locaiton (Map)")
            locationManager.startUpdatingLocation()
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
        if self.data != nil {
            NSLog(NSString(data: self.data!, encoding: NSUTF8StringEncoding)!)
            var deals = parseJSON(self.data!).valueForKey("deals") as NSArray
            for deal in deals as [NSDictionary]   {
                let id = (deal.valueForKey("id") as NSNumber).stringValue
                let name = (deal.valueForKey("info") as NSDictionary).valueForKey("name") as String
                let latlong = deal.valueForKey("latlong") as NSDictionary
                let lat = (latlong.valueForKey("lat") as NSNumber).doubleValue
                let lng = (latlong.valueForKey("lng") as NSNumber).doubleValue
                let annotation = StoreAnnotation(name: name, id: id, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng))
                mapView.addAnnotation(annotation)
            }
            self.data = nil
        }
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        NSLog("\((response as? NSHTTPURLResponse)!.statusCode)")
        if (response as? NSHTTPURLResponse)?.statusCode == 400  {
            var alert = UIAlertController(title: "Invalid Location", message: "Locational input invalid", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else if (response as? NSHTTPURLResponse)?.statusCode == 200 {
            NSLog("Success Loading Map")
            self.data = NSMutableData()
        }
        else if (response as? NSHTTPURLResponse)?.statusCode == 403  {
            var alert = UIAlertController(title: "Invalid Auth Token", message: "There was an authentication error on the server", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else    {
            var alert = UIAlertController(title: "Error", message: "Error loading map content", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    /*func connection(connection: NSURLConnection, didReceiveAuthenticationChallenge challenge: NSURLAuthenticationChallenge) {
        if challenge.previousFailureCount == 0  {
            let creds = NSURLCredential(user: user.token, password: "token", persistence: NSURLCredentialPersistence.None)
            challenge.sender.useCredential(creds, forAuthenticationChallenge: challenge)
        }
        else    {
            challenge.sender.continueWithoutCredentialForAuthenticationChallenge(challenge)
        }
    }*/
}
