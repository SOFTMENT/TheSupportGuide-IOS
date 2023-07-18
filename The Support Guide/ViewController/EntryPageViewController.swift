//
//  EntryPageViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 26/04/23.
//

import UIKit
import Firebase

class EntryPageViewController : UIViewController {
    
    @IBOutlet weak var signUpBtn: UIButton!
    
    @IBOutlet weak var skip: UILabel!
    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewDidLoad() {
        
        
        loginBtn.layer.cornerRadius = 8
        signUpBtn.layer.cornerRadius = 8
        signUpBtn.layer.borderWidth = 1.3
        signUpBtn.layer.borderColor = UIColor(red: 247/255, green: 79/255, blue: 85/255, alpha: 1).cgColor
        
        skip.layer.cornerRadius = 8
        skip.layer.borderColor = UIColor.darkGray.cgColor
        skip.layer.borderWidth = 1.3
        skip.isUserInteractionEnabled = true
        skip.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(skipBtnClicked)))
        
        
        
    }
    
    @objc func skipBtnClicked(){
        self.ProgressHUDShow(text: "")
        Auth.auth().signInAnonymously { result, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                self.beRootScreen(mIdentifier: Constants.StroyBoard.tabBarViewController)
            }
        }
       
    }
 
    @IBAction func loginBtnClicked(_ sender: Any) {
        performSegue(withIdentifier: "signInSeg", sender: nil)
    }
    
    @IBAction func signUpBtnClicked(_ sender: Any) {
        performSegue(withIdentifier: "entryPageSignUpSeg", sender: nil)
    }
    
}
