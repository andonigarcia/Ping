//
//  Landing.swift
//  Ping
//
//  Created by Noah Krim on 2/13/15.
//  Copyright (c) 2015 Ping. All rights reserved.
//

import UIKit
import CoreData

class Landing: UIViewController {

    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSLog("Landing: \(user.token)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dvc = segue.destinationViewController as NavigationController
        dvc.user = user
    }
}

