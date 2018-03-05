//
//  FirebaseHelper.swift
//  TalkToMiPro
//
//  Created by Sikander Zeb on 06/09/2017.
//  Copyright © 2017 Sikander Zeb. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class FirebaseHelper {
    var dbref:DatabaseReference!
    static let shared = FirebaseHelper()
    
    private init() {
        
    }
    
    public func uploadImage(path: String, image: UIImage, completion: ((Error?,String?) -> Swift.Void)? = nil) {
        var data = Data()
        data = UIImageJPEGRepresentation(image, 0.2)!
        // set upload path
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        let metadata = StorageMetadata()
        
        metadata.contentType = "image/jpeg"
        
        storageRef.child(path).putData(data, metadata: metadata){(metaData,error) in
            
            if error != nil {
                completion!(error,nil)
                return
                
            } else{
                //store downloadURL
                let downloadURL = metaData!.downloadURL()!.absoluteString
                completion!(nil,downloadURL)
                
                
            }
            
        }
    }
    
    public static func getArrayFor(_ path: String, completion: ((_ snapshots: [DataSnapshot]?, _ error: NSError?) -> Swift.Void)? = nil) {
        FirebaseHelper.shared.dbref.child(path).observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                
                if completion != nil {
                    completion!(snapshots, nil)
                }
                
//                self.productsArray = []
//                for snap in snapshots {
//                    if let postDict = snap.value as? Dictionary<String, Any> {
//                        let key = snap.key
//                        var category:Category? = nil
//                        
//                        let catKey = postDict["categoryKey"] as? String
//                        
//                        if (self.categoriesArray?.count)! > 0 {
//                            for cat in self.categoriesArray! {
//                                if cat.key == catKey {
//                                    category = cat
//                                    break
//                                }
//                            }
//                        }
//                        
//                        var subCategory:Category? = nil
//                        let subCatKey = postDict["subCategoryKey"] as? String
//                        
//                        if subCatKey != nil {
//                            for cat in (category?.subCategories)! {
//                                if cat.key == subCatKey {
//                                    subCategory = cat
//                                    break
//                                }
//                            }
//                        }
//                        
//                        let form = ProductEntity(key: key, dictionary: postDict, category: category, subCategory: subCategory)
//                        self.productsArray?.append(form)
//                    }
//                }
                
            }
            
            
        }) { (error) in
            print(error.localizedDescription)
            completion!(nil, error as NSError)
        }
    }
    
}
