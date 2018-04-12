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
    
    public init(id: String, dict: Dictionary<String, String>) {
        self.id = id
        
        if dict["video"] != nil {
            video = dict["video"]!
        }
        if dict["caption"] != nil {
            caption = dict["caption"]!
        }
        user = Utilities.shared.userFor(key: dict["userKey"]!)
//        if likes["likes"] != nil {
//            likes = dict["caption"]!
//        }
//        if dict["caption"] != nil {
//            caption = dict["caption"]!
//        }
//        if dict["views"] != nil {
//            views = dict["views"]!
//        }
    }
}
