//
//  StoreView.swift
//  Ping
//
//  Created by Noah Krim on 3/3/15.
//  Copyright (c) 2015 Ping. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class StoreView: UIViewController, MKMapViewDelegate, NSURLConnectionDataDelegate    {
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var storeImage: UIImageView!
    @IBOutlet weak var dealLabel: UILabel!
    @IBOutlet weak var relevantLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var infoLabel1: UILabel!
    @IBOutlet weak var infoLabel2: UILabel!
    @IBOutlet weak var infoLabel3: UILabel!
    @IBOutlet weak var infoLabel4: UILabel!
    @IBOutlet weak var infoLabel5: UILabel!
    
    var locationManager: CLLocationManager!
    var annotation: StoreAnnotation!
    var data:NSMutableData? = nil
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.setToolbarHidden(true, animated: true)
        
        //HTTP Request for store information
        let url = NSURL(string: "http://www.igotpinged.com/mobile/api/v0.1/users/\(user.user_id)/map/\(annotation.id)".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        var request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        let loginString = "\(user.token):token"
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(nil)
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        /*//Dictionary to be converted to JSON
        var dict:[NSString:NSDictionary] = Dictionary()
        var latlong:[NSString:NSNumber] = Dictionary()
        latlong["lat"] = locationManager.location.coordinate.latitude
        latlong["lng"] = locationManager.location.coordinate.longitude
        dict["location"] = NSDictionary(dictionary: latlong)
        NSLog(NSString(data: NSJSONSerialization.dataWithJSONObject(NSDictionary(dictionary: dict), options: nil, error: nil)!, encoding: NSUTF8StringEncoding)!)
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(NSDictionary(dictionary: dict), options: nil, error: nil)
        NSLog(NSString(data: request.HTTPBody!, encoding: NSUTF8StringEncoding)!)*/
        var connection = NSURLConnection(request: request, delegate: self, startImmediately: true)
        
        //Set Label Values
        navItem.title = annotation.name
        dealLabel.lineBreakMode = .ByWordWrapping
        dealLabel.numberOfLines = 0
        
        //Set Map Region
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        locationManager = appDelegate.locationManager as CLLocationManager
        if(CLLocationManager.locationServicesEnabled() == true) {
            let centerLat = (annotation.coordinate.latitude + locationManager.location.coordinate.latitude)/2
            let centerLon = (annotation.coordinate.longitude + locationManager.location.coordinate.longitude)/2
            let centerPoint = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon)
            var sizeWidth: Double
            if(annotation.coordinate.latitude >= locationManager.location.coordinate.latitude)    {
                sizeWidth = annotation.coordinate.latitude - locationManager.location.coordinate.latitude
            }
            else    {
                sizeWidth = locationManager.location.coordinate.latitude - annotation.coordinate.latitude
            }
            sizeWidth *= 1.5
            var sizeHeight: Double
            if(annotation.coordinate.longitude >= locationManager.location.coordinate.longitude)    {
                sizeHeight = annotation.coordinate.longitude - locationManager.location.coordinate.longitude
            }
            else    {
                sizeHeight = locationManager.location.coordinate.longitude - annotation.coordinate.longitude
            }
            sizeHeight *= 1.5
            let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(sizeWidth, sizeHeight)
            let theRegion:MKCoordinateRegion = MKCoordinateRegionMake(centerPoint, theSpan)
            mapView.setRegion(theRegion, animated: true)
            mapView.addAnnotation(annotation)
            
            let request = MKDirectionsRequest()
            request.setSource(MKMapItem.mapItemForCurrentLocation())
            request.setDestination(MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude), addressDictionary: nil)))
            request.requestsAlternateRoutes = false
            
            let directions = MKDirections(request: request)
            
            directions.calculateDirectionsWithCompletionHandler({(response:
                MKDirectionsResponse!, error: NSError!) in
                
                if error != nil {
                    // Handle error
                } else {
                    self.showRoute(response)
                }
                
            })
        }
    }
    
    //MAP FUNCTIONALITIES

    func showRoute(response: MKDirectionsResponse) {
        for route in response.routes as [MKRoute] {
            mapView.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
        }
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay
        overlay: MKOverlay!) -> MKOverlayRenderer! {
            let renderer = MKPolylineRenderer(overlay: overlay)
            
            renderer.strokeColor = UIColor.blueColor()
            renderer.lineWidth = 5.0
            return renderer
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
            var annotItem:MKMapItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude), addressDictionary: nil))
            annotItem.name = navItem.title
            annotItem.phoneNumber = (infoLabel5.text != "" ? infoLabel5.text : infoLabel4.text)
            annotItem.openInMapsWithLaunchOptions(nil)
        }
    }
    
    //INTERNET FUNCTIONALITIES
    
    func parseJSON(inputData: NSData) -> NSDictionary{
        var error: NSError?
        var dict: NSDictionary = NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
        
        return dict
    }
    
    func connection(connection: NSURLConnection!, didReceiveData _data: NSData!)
    {
        NSLog("didReceiveData")
        self.data?.appendData(_data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!)
    {
        if self.data != nil {
            var info: NSDictionary = NSDictionary()
            if connection.currentRequest.URL == NSURL(string: "http://www.igotpinged.com/mobile/api/v0.1/users/\(user.user_id)/map/\(annotation.id)".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)    {
                NSLog(NSString(data: self.data!, encoding: NSUTF8StringEncoding)!)
                var dict = parseJSON(self.data!).valueForKey("deal") as NSDictionary
                dealLabel.text = dict.valueForKey("deal") as? String
                info = dict.valueForKey("info") as NSDictionary
                infoLabel1.text = info.valueForKey("address1") as? String
                let address2 = info.valueForKey("address2") as? String
                let a2Exists = address2 != nil && address2 != ""
                if a2Exists {
                    infoLabel2.text = address2
                    infoLabel3.text = (info.valueForKey("city") as String)+", "+(info.valueForKey("state") as String)
                    infoLabel4.text = info.valueForKey("zipcode") as? String
                    infoLabel5.text = info.valueForKey("phone") as? String
                }
                else    {
                    infoLabel2.text = (info.valueForKey("city") as String)+", "+(info.valueForKey("state") as String)
                    infoLabel3.text = info.valueForKey("zipcode") as? String
                    infoLabel4.text = info.valueForKey("phone") as? String
                    infoLabel5.text = ""
                }
                let name = info.valueForKey("name") as String
                if name != navItem.title    {
                    navItem.title = name
                }
                let logoURL = info.valueForKey("logo") as? String
                if logoURL != nil && logoURL != ""  {
                    NSLog(NSString(contentsOfURL: connection.currentRequest.URL, encoding: NSUTF8StringEncoding, error: nil)!)
                    //HTTP Request for store logo
                    let url = NSURL(string: "http://www.igotpinged.com/\(logoURL!)".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
                    var request = NSURLRequest(URL: url!)
                    var connection = NSURLConnection(request: request, delegate: self, startImmediately: true)
                }
            }
            else    {
                storeImage.image = UIImage(data: self.data!)
            }
            self.data = nil
        }
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        NSLog("\((response as? NSHTTPURLResponse)!.statusCode)")

        if connection.currentRequest.URL == NSURL(string: "http://www.igotpinged.com/mobile/api/v0.1/users/\(user.user_id)/map/\(annotation.id)".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)    {
            if (response as? NSHTTPURLResponse)?.statusCode == 400  {
                var alert = UIAlertController(title: "Company Not Found", message: "Information for the companies current deal does not exist", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Exit", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                self.navigationController?.popViewControllerAnimated(true)
            }
            else if (response as? NSHTTPURLResponse)?.statusCode == 200 {
                self.data = NSMutableData()
            }
            else if (response as? NSHTTPURLResponse)?.statusCode == 403  {
                var alert = UIAlertController(title: "Invalid Auth Token", message: "There was an authentication error on the server; you must re-login", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
            else    {
                var alert = UIAlertController(title: "Error", message: "Error loading store information", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        else    {
            if (response as? NSHTTPURLResponse)?.statusCode == 200 {
                self.data = NSMutableData()
            }
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