//
//  RegisterViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 26/04/23.
//

import UIKit
import Firebase
import CropViewController

class RegisterViewController : UIViewController {
    
    
    @IBOutlet weak var backView: UIView!
   
    
    @IBOutlet weak var fullName: UITextField!
    
    @IBOutlet weak var emailAddress: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var registerBtn: UIButton!
    
    @IBOutlet weak var loginNow: UILabel!

    
    override func viewDidLoad() {
        
       
        

        fullName.delegate = self
   
        emailAddress.delegate = self
        
        password.delegate = self
        
        loginNow.isUserInteractionEnabled = true
        loginNow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(signInClicked)))
        
        
        registerBtn.layer.cornerRadius = 8
        
        backView.isUserInteractionEnabled = true
        backView.layer.cornerRadius = 12
        backView.dropShadow()
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    @objc func signInClicked(){
        performSegue(withIdentifier: "signInSegFromSignUp", sender: nil)
    }
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    
    @IBAction func registerBtnClicked(_ sender: Any) {
        
        
        let sFullName = fullName.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sEmail = emailAddress.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sPassword = password.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if sFullName == "" {
            self.showToast(message:  "Enter Full Name")
        }
        else if sEmail == "" {
            self.showToast(message:  "Enter Email")
        }
        else if sPassword  == "" {
            self.showToast(message:  "Enter Password")
        }
        else {
            ProgressHUDShow(text: "Creating Account...")
            Auth.auth().createUser(withEmail: sEmail!, password: sPassword!) { result, error in
                self.ProgressHUDHide()
                if error == nil {
                    let userData = UserModel()
                    userData.fullName = sFullName
                    userData.email = sEmail
                    userData.uid = Auth.auth().currentUser!.uid
                    userData.registredAt = Date()
                    userData.regiType = "custom"
                    self.addUserData(userData: userData)
                
                }
                else {
                    self.showError(error!.localizedDescription)
                }
            }
        }
        
    }


    
}

extension RegisterViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.hideKeyboard()
        return true
    }
}
