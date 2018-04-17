//
//  Post.swift
//  Tubelio
//
//  Created by Sikander Zeb on 3/13/18.
//  Copyright © 2018 Sikander. All rights reserved.
//

import UIKit

class Post {
    var id = ""
    var user: UserEntity? = nil
    var video: String = ""
    var caption: String = ""
    var likes: [UserEntity] = []
    var comments: [Comment] = []
    var views: [UserEntity] = []
    
    public init(id: String, dict: Dictionary<String, Any>) {
        self.id = id
        
        if dict["video"] != nil {
            video = dict["video"] as! String
        }
        if dict["caption"] != nil {
            caption = dict["caption"] as! String
        }
        user = Utilities.shared.userFor(key: dict["userKey"] as! String)
        if let array = dict["likes"] as? Dictionary<String, Any> {
            for d in array.keys {
                if let u = Utilities.shared.userFor(key: d) {
                    self.likes.append(u)
                }
            }
        }
        
        if let array = dict["comments"] as? Dictionary<String, Any> {
            for d in array.keys {
                var dict = array[d] as! Dictionary<String, String>
                dict["id"] = d
                self.comments.append(Comment(dict: dict))
            }
        }
        
    }
}
