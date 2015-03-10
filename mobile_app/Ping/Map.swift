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
    var data = NSMutableData()
    
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
        
        if(CLLocationManager.authorizationStatus() != .Authorized)  {
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
            //HTTP request to get map information
            let url = NSURL(string: "http://localhost:5000/mobile/api/v0.1/users/\(user.user_id)/map".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
            var request = NSMutableURLRequest(URL: url!)
            request.HTTPMethod = "GET"
            request.HTTPBody = ""
            var connection = NSURLConnection(request: request, delegate: self, startImmediately: true)
        }
    }
    
    func pressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(sender as? StoreAnnotation != nil)  {
            var dvc: StoreView = segue.destinationViewController as StoreView
            dvc.annotation = sender as StoreAnnotation
            dvc.user = user
        }
        else if(sender as? UIBarButtonItem == settingsButton)   {
            var dvc:Settings = segue.destinationViewController as Settings
            dvc.delegate = self
            dvc.user = user
        }
    }
    
    //MAP FUNCTIONALITIES
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        NSLog("Did update location")
        let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(0.01 , 0.01)
        let theRegion:MKCoordinateRegion = MKCoordinateRegionMake(locationManager.location.coordinate, theSpan)
        mapView.setRegion(theRegion, animated: true)
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!)    {
        let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(0.01 , 0.01)
        let theRegion:MKCoordinateRegion = MKCoordinateRegionMake(locationManager.location.coordinate, theSpan)
        mapView.setRegion(theRegion, animated: true)
    }
    
    func addStoreAnnotation(store: Store)    {
        let annotation = StoreAnnotation(store: store, coordinate: store.coordinate)
        mapView.addAnnotation(annotation)
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
        if(status == .Authorized)   {
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
        self.data.appendData(_data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!)   {
        var dict = parseJSON(self.data)
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        if (response as? NSHTTPURLResponse)?.statusCode == 400  {
            var alert = UIAlertController(title: "Failed Register", message: "Registration failed", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else if (response as? NSHTTPURLResponse)?.statusCode == 200 {
            self.data = NSMutableData()
        }
        else    {
            var alert = UIAlertController(title: "Error", message: "Error registering", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}
