//
//  StoreAnnotation.swift
//  Ping
//
//  Created by Noah Krim on 3/3/15.
//  Copyright (c) 2015 Ping. All rights reserved.
//

import Foundation
import MapKit

class StoreAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var title: String = ""
    var name: String = ""
    var id: String = ""
    var imageURL: String = ""
    
    override init()  {
        super.init()
    }
    
    init(name: String, id: String, imageURL: String, coordinate: CLLocationCoordinate2D) {
        super.init()
        self.name = name
        self.title = name
        self.setCoordinate(coordinate)
        self.id = id
        self.imageURL = imageURL
    }
    
    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        coordinate = newCoordinate
    }
}