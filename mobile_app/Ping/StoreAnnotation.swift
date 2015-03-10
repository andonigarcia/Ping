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
    var store: Store = Store()
    var title: String = ""
    
    override init()  {
        super.init()
    }
    
    init(store: Store, coordinate: CLLocationCoordinate2D) {
        super.init()
        self.store = store
        self.setCoordinate(coordinate)
        self.title = store.name
    }
    
    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        coordinate = newCoordinate
    }
}