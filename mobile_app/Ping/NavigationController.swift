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

    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.tintColor = UIColor.whiteColor()
        //navigationBar.barTintColor = UIColor(red: 191/255.0, green: 20/255.0, blue: 170/255.0, alpha: 1.0)
        navigationBar.barTintColor = UIColor(red: 172/255.0, green: 57/255.0, blue: 157/255.0, alpha: 1.0)
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor(), NSFontAttributeName:UIFont(name: "Courgette", size: 32)!]
        toolbar.tintColor = UIColor.whiteColor()
        //toolbar.barTintColor = UIColor(red: 191/255.0, green: 20/255.0, blue: 170/255.0, alpha: 1.0)
        toolbar.barTintColor = UIColor(red: 172/255.0, green: 57/255.0, blue: 157/255.0, alpha: 1.0)
        
        NSLog(user.token)
        if user.token != "" {
            //self.viewControllers[0] = Login()
            performSegueWithIdentifier("toMap", sender: user)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        super.preferredStatusBarStyle()
        return UIStatusBarStyle.LightContent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if sender as? User != nil   {
            let dvc = segue.destinationViewController as Map
            dvc.user = user
            dvc.delegate = self.viewControllers[0] as Login
        }
    }
}
