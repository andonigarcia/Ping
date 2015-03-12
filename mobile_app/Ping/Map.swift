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
            //HTTP request to get map information
            let url = NSURL(string: "http://localhost:5000/mobile/api/v0.1/users/\(user.user_id)/map".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
            var request = NSMutableURLRequest(URL: url!)
            request.setValue("Basic \(user.token):token", forHTTPHeaderField: "Authentication")
            request.HTTPMethod = "GET"
            //Dictionary to be converted to JSON
            var dict = ["location":["lat":locationManager.location.coordinate.latitude, "lng":locationManager.location.coordinate.longitude]]
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(NSDictionary(dictionary: dict), options: nil, error: nil)
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
        self.data.appendData(_data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!)   {
        var deals = parseJSON(self.data).valueForKey("deals") as NSArray
        for deal in deals as [NSDictionary]   {
            let id = deal.valueForKey("id") as String
            let name = (deal.valueForKey("info") as NSDictionary).valueForKey("name") as String
            let latlong = deal.valueForKey("latlong") as NSDictionary
            let lat = (deal.valueForKey("lat") as NSString).doubleValue
            let lng = (deal.valueForKey("lng") as NSString).doubleValue
            let annotation = StoreAnnotation(name: name, id: id, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng))
            mapView.addAnnotation(annotation)
        }
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        if (response as? NSHTTPURLResponse)?.statusCode == 400  {
            var alert = UIAlertController(title: "Invalid Location", message: "Locational input invalid", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else if (response as? NSHTTPURLResponse)?.statusCode == 200 {
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
}
