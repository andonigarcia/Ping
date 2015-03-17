//
//  User.swift
//  Ping
//
//  Created by Noah Krim on 3/9/15.
//  Copyright (c) 2015 Ping. All rights reserved.
//

import Foundation

class User  {
    var name: String
    var user_id: Int
    var token: String
    var age: Int
    var email: String
    
    init() {
        name = ""
        user_id = 0
        token = ""
        age = 0
        email = ""
    }
    
    init(user_id: Int, token: String)    {
        name = ""
        self.user_id = user_id
        self.token = token
        age = 0
        email = ""
    }
    
    init(name: String, user_id: Int, token: String, age: Int, email: String) {
        self.name = name
        self.user_id = user_id
        self.token = token
        self.age = age
        self.email = email
    }
}
