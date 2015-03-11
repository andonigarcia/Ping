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
    var name: String = ""
    var id: String = ""
    
    override init()  {
        super.init()
    }
    
    init(name: String, id: String, coordinate: CLLocationCoordinate2D) {
        super.init()
        self.name = name
        self.setCoordinate(coordinate)
        self.id = id
    }
    
    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        coordinate = newCoordinate
    }
}