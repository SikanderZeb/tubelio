//
//  ShareVC.swift
//  Tubelio
//
//  Created by Sikander Zeb on 3/4/18.
//  Copyright © 2018 Sikander. All rights reserved.
//

import UIKit
import AVKit
import SVProgressHUD
import Firebase

class ShareVC: BaseVC {

    var asset: AVURLAsset!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var facebookSwitch: UISwitch!
    @IBOutlet weak var instaSwitch: UISwitch!
    @IBOutlet weak var googleSwitch: UISwitch!
    @IBOutlet weak var twitterSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func publish(_ sender: UIButton) {
        if Utilities.isEmpty(caption.text) {
            Utilities.showAlert(self, message: "Please enter caption", alertTitle: "Missing Caption")
            return
        }
        
        let weakself = self
        let block = {(error: Error?, ref: DatabaseReference ) in
            if error != nil {
                SVProgressHUD.dismiss()
                
                Utilities.showAlert(self, message: "Error posting video \(error?.localizedDescription ?? "")", alertTitle: "Error")
                return
                
            }
            
            let filePath = "posts/\(ref.key)/"
            
            let dbref = ref
            let data = try! Data(contentsOf: self.asset.url)
            
            FirebaseHelper.shared.uploadVideo(path: filePath, video: data, completion: { (error, downloadURL) in
                if error != nil {
                    SVProgressHUD.dismiss()
                    Utilities.showAlert(self, message: "Error uploading video \(error?.localizedDescription ?? "")", alertTitle: "Error")
                    return
                }
                
                dbref.updateChildValues(["video":downloadURL ?? "none"], withCompletionBlock: { (error, ref) in
                    SVProgressHUD.dismiss()
                    
                    if error != nil {
                        Utilities.showAlert(self, message: "Error updating image path \(error?.localizedDescription ?? "")", alertTitle: "Error")
                        return
                    }
                    weakself.navigationController?.popToRootViewController(animated: true)
                    Utilities.showAlert(self, message: "Video uploaded successfully", alertTitle: "Success")
                    
                })
            })
        
        }
        
        var dictionary: Dictionary<String,String>? = nil
        
        dictionary = ["caption":caption.text!,
                        "userKey":(Auth.auth().currentUser?.uid)!,
                        "video":"none"]
        
        SVProgressHUD.show()
        FirebaseHelper.shared.dbref.child("posts").childByAutoId().setValue(dictionary, withCompletionBlock:block)

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
