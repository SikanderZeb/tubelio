//
//  Comment.swift
//  Tubelio
//
//  Created by Sikander Zeb on 3/13/18.
//  Copyright © 2018 Sikander. All rights reserved.
//

import UIKit

class Comment {
    var id = ""
    var comment = ""
    var uid = ""
    
    public init(dict: Dictionary<String, String>) {
        if dict["id"] != nil {
            id = dict["id"]!
        }
        if dict["comment"] != nil {
            comment = dict["comment"]!
        }
        if dict["uid"] != nil {
            uid = dict["uid"]!
        }
    }
}
