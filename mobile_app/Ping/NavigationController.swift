//
//  NavigationController.swift
//  Ping
//
//  Created by Noah Krim on 2/15/15.
//  Copyright (c) 2015 Ping. All rights reserved.
//

import Foundation
import UIKit

class NavigationController: UINavigationController  {
    
    var username: NSString = ""
    
    override func viewDidLoad() {
        (self.viewControllers[0] as Map).username = self.username
    }
}
