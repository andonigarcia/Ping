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
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var storeImage: UIImageView!
    @IBOutlet weak var dealLabel: UILabel!
    @IBOutlet weak var relevantLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager!
    var annotation: StoreAnnotation!
    var data = NSMutableData()
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.setToolbarHidden(true, animated: true)
        
        //HTTP Request for store information (Specifically store image)
        let url = NSURL(string: "http://www.newsgeneration.com/newsgenwp/wp-content/uploads/2014/09/Starbucks-free-to-use.jpg".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        var request = NSURLRequest(URL: url!)
        var connection = NSURLConnection(request: request, delegate: self, startImmediately: true)
        
        //Set Label Values
        navItem.title = annotation.store.name
        infoLabel.text = annotation.store.name
        dealLabel.text = annotation.store.deal
        
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
        }
    }
    
    func connection(connection: NSURLConnection!, didReceiveData _data: NSData!)
    {
        NSLog("didReceiveData")
        self.data.appendData(_data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!)
    {
        //If the request was for image, assign image to storeImage
        storeImage.image = UIImage(data: data)
    }
}