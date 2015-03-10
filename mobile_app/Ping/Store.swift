//
//  Store.swift
//  Ping
//
//  Created by Noah Krim on 3/3/15.
//  Copyright (c) 2015 Ping. All rights reserved.
//

import Foundation
import CoreLocation

class Store {
    var name: String
    var info: String
    var coordinate: CLLocationCoordinate2D
    var deal: String
    
    init()  {
        name = ""
        info = ""
        coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        deal = ""
    }
    
    init(name: String, info: String, coordinate: CLLocationCoordinate2D, deal: String) {
        self.name = name
        self.info = info
        self.coordinate = coordinate
        self.deal = deal
    }
}
