//
//  User.swift
//  Tubelio
//
//  Created by Sikander Zeb on 3/13/18.
//  Copyright © 2018 Sikander. All rights reserved.
//

import UIKit

class UserEntity {
    var id = ""
    var name = ""
    var email = ""
    
    public init(id: String, dict: Dictionary<String, String>) {
        self.id = id
        if dict["name"] != nil {
            name = dict["name"]!
        }
        if dict["email"] != nil {
            email = dict["email"]!
        }
    }
}
