//
//  Constants.swift
//  TalkToMiPro
//
//  Created by Sikander Zeb on 21/08/2017.
//  Copyright © 2017 Sikander Zeb. All rights reserved.
//

import Foundation
import SVProgressHUD

class Constants {
    
    struct URLs {
        public static let SERVER_URL = "http://scryapp.com/"
    }
    
    struct STRINGS {
        public static let PROFILE = "profile"
    }
    
    public static let BLUE_COLOR = UIColor(displayP3Red: 28/255.0, green: 155/255.0, blue: 224/255.0, alpha: 1.0)
    public static let BLUE_DARK_COLOR = UIColor(displayP3Red: 22/255.0, green: 110/255.0, blue: 210/255.0, alpha: 1.0)
    
    public static let Categories: Array = ["Food","Tech","Fun","Fashion","XFX","Buy for you","Sharing","Selling"]
    public static let Types: Array = ["Food","Tech","Fun","Fashion"]
    public static let Time: Array = ["15 mins","30 mins","45 mins","60 mins","75 mins","90 mins","105 mins","120 mins"]
}
