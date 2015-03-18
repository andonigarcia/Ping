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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.tintColor = UIColor.whiteColor()
        //navigationBar.barTintColor = UIColor(red: 191/255.0, green: 20/255.0, blue: 170/255.0, alpha: 1.0)
        navigationBar.barTintColor = UIColor(red: 172/255.0, green: 57/255.0, blue: 157/255.0, alpha: 1.0)
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor(), NSFontAttributeName:UIFont(name: "Courgette", size: 32)!]
        toolbar.tintColor = UIColor.whiteColor()
        //toolbar.barTintColor = UIColor(red: 191/255.0, green: 20/255.0, blue: 170/255.0, alpha: 1.0)
        toolbar.barTintColor = UIColor(red: 172/255.0, green: 57/255.0, blue: 157/255.0, alpha: 1.0)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        super.preferredStatusBarStyle()
        return UIStatusBarStyle.LightContent
    }
}
