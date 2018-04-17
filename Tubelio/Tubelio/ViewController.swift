//
//  ViewController.swift
//  Tubelio
//
//  Created by Sikander on 2/20/18.
//  Copyright © 2018 Sikander. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import SVProgressHUD

class ViewController: BaseVC {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    //@IBOutlet weak var confirmPassword: UITextField!
    //@IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseHelper.shared.dbref = Database.database().reference()
    }
    
    @IBAction func registerTapped(_ sender: Any) {
        
//        if Utilities.isEmpty(phoneNumber.text!) || (phoneNumber.text?.characters.count)! < 8 {
//            Utilities.showAlert(self, message: "Phone number should be minimum 8 characters", alertTitle: "Invalid Phone")
//            return
//        }
        
        if !Utilities.isValidEmail(testStr: email.text!) {
            Utilities.showAlert(self, message: "Please enter a valid email address", alertTitle: "Invalid Email")
            return
        }
        
        if Utilities.isEmpty(username.text!) {
            Utilities.showAlert(self, message: "Username cannot be empty", alertTitle: "Invalid Phone")
            return
        }
        
        if Utilities.isEmpty(password.text!) {
            Utilities.showAlert(self, message: "Please enter a password", alertTitle: "Empty Password")
            return
        }
        
//        if password.text! != confirmPassword.text! {
//            Utilities.showAlert(self, message: "Passwords do not match", alertTitle: "Password")
//            return
//        }
        
        SVProgressHUD.show()
        Auth.auth().createUser(withEmail: email.text!, password: password.text!, completion: { (user, error) in
            
            SVProgressHUD.dismiss()
            
            if error != nil {
                print(error ?? "")
                Utilities.showAlert(self, message: (error?.localizedDescription)!, alertTitle: "Error")
                return
            }
            
//            user?.sendEmailVerification(completion: { (error) in
//                if error != nil {
//                    print("error verifying email: \(error ?? nil )")
//                    Utilities.showAlert(self, message: "A verification email has been sent to provided email address, please verify.", alertTitle: "Success")
//                }
//            })
            
            let request = user?.createProfileChangeRequest()
            request?.displayName = self.username.text!
            request?.commitChanges(completion: { (error) in
                
                Utilities.saveProfile(Auth.auth().currentUser!, password: self.password.text)
            })
            
            FirebaseHelper.shared.dbref.child("users/\((user?.uid)!)").setValue(["name": self.username.text!,
                                                                                 "email":self.email.text!,])
            self.performSegue(withIdentifier: "goToHomeSegue"/*loginSegue*/, sender: self)
            //print(user)
        })
        
    }
    
    @IBAction func recoverTapped(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Recover Password", message: "", preferredStyle: .alert)
        alert.addTextField { (textfield) in
            textfield.placeholder = "Your email"
            textfield.keyboardType = .emailAddress
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            let textfield = alert.textFields![0]
            
            if !Utilities.isValidEmail(testStr: textfield.text!) {
                Utilities.showAlert(self, message: "Please enter a valid email address", alertTitle: "Invalid Email")
                return
            }
            SVProgressHUD.show()
            Auth.auth().sendPasswordReset(withEmail: textfield.text!) { (error) in
                SVProgressHUD.dismiss()
                if error != nil {
                    
                    Utilities.showAlert(self, message: (error?.localizedDescription)!, alertTitle: "Error")
                    return
                }
                
                Utilities.showAlert(self, message: "Check your email for new password", alertTitle: "Success")
            }
        }))
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        if !Utilities.isValidEmail(testStr: email.text!) {
            Utilities.showAlert(self, message: "Please enter a valid email address", alertTitle: "Invalid Email")
            return
        }
        
        if Utilities.isEmpty(password.text!) {
            Utilities.showAlert(self, message: "Please enter a password", alertTitle: "Empty Password")
            return
        }
        
        SVProgressHUD.show()
        
        Auth.auth().signIn(withEmail: email.text! , password: password.text!, completion: { (user, error) in
            SVProgressHUD.dismiss()
            if error != nil {
                print(error ?? "")
                Utilities.showAlert(self, message: (error?.localizedDescription)!, alertTitle: "Error")
                return
            }
            Utilities.saveProfile(user!, password: self.password.text)
            self.performSegue(withIdentifier: "goToHomeSegue", sender: self)
            //print(user)
        })
    }
}

class BaseVC: UIViewController, UITextFieldDelegate {
    override func viewDidLoad() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
