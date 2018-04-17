//
//  Utilities.swift
//  PT Chat
//
//  Created by Sikander Zeb on 17/07/2017.
//  Copyright © 2017 Sikander Zeb. All rights reserved.
//

// com.adland.Scry

import UIKit
import AFNetworking
import SVProgressHUD
import Firebase

class Utilities: NSObject {
    
    //var categoriesArray: Array<Category>? = []
    var productsArray: Array<Post>? = []
    var usersArray: Array<UserEntity>? = []
    
    static let shared = Utilities()
    
    static var filterCategory: String? = nil
    
    private override init() { }
    
    //MARK: Server Requests
    public static func serverRequest(_ url:String, paramters:NSDictionary,  completionBlock: @escaping (_ responseObject: NSDictionary) -> Void, errorBlock: @escaping (_ error: NSError) -> Void ) {
        
        let manager = AFHTTPSessionManager.init(sessionConfiguration: URLSessionConfiguration.default)
        manager.responseSerializer = AFJSONResponseSerializer.init(readingOptions: JSONSerialization.ReadingOptions.allowFragments)
        manager.responseSerializer.acceptableContentTypes = (NSSet.init(objects: "text/html","text/plain","application/json") as! Set<String>)
        manager.requestSerializer.timeoutInterval = 10.0
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        SVProgressHUD.show()
        let url = "\(Constants.URLs.SERVER_URL)\(url)"
        print("paramters are :",paramters, url)
        
        manager.get(url, parameters: paramters, progress: nil, success: { (task, response ) in
            
            SVProgressHUD.dismiss()
            print("resposne is:", response!)
            completionBlock(response as! NSDictionary)
        }) { (task, error) in
            SVProgressHUD.dismiss()
            
            print("Error is:", error)
            errorBlock(error as NSError)
        }
    }
    
    public static func serverRequestBackground(_ url:String, paramters:NSDictionary,  completionBlock: (_ responseObject: NSDictionary) -> Void, errorBlock: @escaping (_ error: NSError) -> Void ) {
        
        let manager = AFHTTPSessionManager.init(sessionConfiguration: URLSessionConfiguration.default)
        manager.responseSerializer = AFJSONResponseSerializer.init(readingOptions: JSONSerialization.ReadingOptions.allowFragments)
        manager.responseSerializer.acceptableContentTypes = (NSSet.init(objects: "text/html","text/plain","application/json") as! Set<String>)
        manager.requestSerializer.timeoutInterval = 10.0
        let url = "\(Constants.URLs.SERVER_URL)\(url)"
        print("paramters are :",paramters)
        manager.get(url, parameters: paramters, progress: nil, success: { (task, response) in
            
        }) { (task, error) in
            let er = error as NSError
            if er.code != 400 {
                Utilities.showAlert((UIApplication.shared.keyWindow?.rootViewController)!, message: error.localizedDescription, alertTitle: "Network Error")
            }
            else {
                 errorBlock(er)
            }
           
        }
    }
    
    
    //MARK: Helpers
    public static func isEmpty(_ string:String) -> Bool {

        if (string.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).characters.count == 0 ) {
            return true
        }
        
        return false
    }
    
    public static func isValidEmail(testStr:String) -> Bool {
        
        if (Utilities.isEmpty(testStr)) {
            return false
        }
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    public static func showAlert(_ controller:UIViewController, message:String, alertTitle:String ) {
        
        let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
        controller.present(alert, animated: true, completion: nil)
        
    }
    
    public static func setNavigationBar(_ controller:UIViewController) {
        let nc = controller.navigationController
        nc?.navigationBar.tintColor = UIColor.white
        nc?.navigationBar.shadowImage = UIImage()
        nc?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        nc?.navigationBar.isTranslucent = true
        nc?.navigationBar.backgroundColor = UIColor.clear
        
    }
    
    public static func saveProfile(_ profile: User, password: String!) {
        
        if password == nil {
            
            if let p = UserDefaults.standard.dictionary(forKey: Constants.STRINGS.PROFILE) {
                let dictionary = ["name":profile.displayName ?? "",
                                  "uid":profile.uid,
                                  "email":profile.email,
                                  "password":p["password"] as? String]
                UserDefaults.standard.set(dictionary, forKey: Constants.STRINGS.PROFILE)
                
                return
            }
        }
        
        let dictionary = ["name":profile.displayName ?? "",
                          "uid":profile.uid,
                          "email":profile.email,
                          "password":password]
        UserDefaults.standard.set(dictionary, forKey: Constants.STRINGS.PROFILE)
    }
    
    public static func getProfile() -> Dictionary<String, String>! {
        if UserDefaults.standard.object(forKey: Constants.STRINGS.PROFILE) == nil {
            return nil
        }
        return UserDefaults.standard.object(forKey: Constants.STRINGS.PROFILE) as! Dictionary<String,String>
    
    }
    
    public func updateProducts(completion: (() -> Swift.Void)? = nil)  {
        
        self.updateUsers {
            FirebaseHelper.shared.dbref.child("posts").observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                    
                    self.productsArray = []
                    for snap in snapshots {
                        if let postDict = snap.value as? Dictionary<String, Any> {
                            let key = snap.key
                            let form = Post(id: key, dict: postDict)
                            
                            self.productsArray?.append(form)
                        }
                    }
                    
                    
                }
                if completion != nil {
                    completion!()
                }
                
                
            }) { (error) in
                print(error.localizedDescription)
            }
        } // users closed
        
    }
    
    public func updateUsers(completion: (() -> Swift.Void)? = nil)  {
        FirebaseHelper.shared.dbref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {

                self.usersArray = []
                for snap in snapshots {
                    if let postDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        if let dict = postDict as? Dictionary<String, String> {
                            let form = UserEntity(id: key, dict: dict)
                            self.usersArray?.append(form)
                        }
                    }
                }

            }
            if completion != nil {
                completion!()
            }


        }) { (error) in
            print(error.localizedDescription)
        }
    }

    public func userFor(key: String) -> UserEntity? {
      let users = Utilities.shared.usersArray?.filter {
            (($0.id).range(of: key, options: [.diacriticInsensitive, .caseInsensitive]) != nil)
        }

        if (users?.count)! > 0 {return (users?[0])!}

        return nil
    }
}

extension Dictionary {
    func nullKeyRemoval() -> [AnyHashable: Any] {
        var dict: [AnyHashable: Any] = self
        
        let keysToRemove = dict.keys.filter { dict[$0] is NSNull }
        let keysToCheck = dict.keys.filter({ dict[$0] is Dictionary })
        for key in keysToRemove {
            dict.removeValue(forKey: key)
        }
        for key in keysToCheck {
            if let valueDict = dict[key] as? [AnyHashable: Any] {
                dict.updateValue(valueDict.nullKeyRemoval(), forKey: key)
            }
        }
        return dict
    }
}

//extension UIViewController: UITextFieldDelegate {
//    
//    //MARK: UITextfield delegate
//    public func textFieldDidBeginEditing(_ textField: UITextField) {
////        [UIView beginAnimations:nil context:NULL];
////        [UIView setAnimationDelegate:self];
////        [UIView setAnimationDuration:0.3];
////        [UIView setAnimationBeginsFromCurrentState:YES];
////        self.view.frame = CGRectMake(self.view.frame.origin.x, (self.view.frame.origin.y - 100.0), self.view.frame.size.width, self.view.frame.size.height);
////        [UIView commitAnimations];
//
//        UIView.beginAnimations(nil, context: nil)
//        UIView.setAnimationDelegate(self)
//        UIView.setAnimationDuration(0.3)
//        UIView.setAnimationBeginsFromCurrentState(true)
//        self.view.frame = CGRect(x: self.view.frame.origin.x, y: (self.view.frame.origin.y - 100.0), width: self.view.frame.size.width, height:  self.view.frame.size.height)
//        UIView.commitAnimations()
//        
//    }
//    
//    public func textFieldDidEndEditing(_ textField: UITextField) {
//        
//        if self.view.frame.origin.y == 0 {
//            return
//        }
//        
//        UIView.beginAnimations(nil, context: nil)
//        UIView.setAnimationDelegate(self)
//        UIView.setAnimationDuration(0.3)
//        UIView.setAnimationBeginsFromCurrentState(true)
//        self.view.frame = CGRect(x: self.view.frame.origin.x, y: 0, width: self.view.frame.size.width, height:  self.view.frame.size.height)
//        UIView.commitAnimations()
//    }
//    
//    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
//    
//    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)
//    }
//    
//}
//
