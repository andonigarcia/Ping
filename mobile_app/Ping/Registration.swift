//
//  Registration.swift
//  Ping
//
//  Created by Noah Krim on 2/14/15.
//  Copyright (c) 2015 Ping. All rights reserved.
//

import Foundation
import UIKit

class Registration: UIViewController    {
    
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordreentryField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
        cancelButton.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
    }
    
    func pressed(sender: UIButton!)  {
        if(sender == submitButton)  {
            //TO ADD INTERNET FEATURES!!
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}