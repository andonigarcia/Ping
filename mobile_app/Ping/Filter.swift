//
//  Filter.swift
//  Ping
//
//  Created by Noah Krim on 2/15/15.
//  Copyright (c) 2015 Ping. All rights reserved.
//

import Foundation
import UIKit

class Filter: UIViewController  {
    
    @IBOutlet weak var dealtypeControl: UISegmentedControl!
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var sortPicker: UIPickerView!
    
    var username: NSString = ""
}
