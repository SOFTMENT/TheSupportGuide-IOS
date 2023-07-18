//
//  FranchiseCopyEmailPasswordViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 20/05/23.
//

import UIKit

class FranchiseCopyEmailPasswordViewController : UIViewController {
    
    
    @IBOutlet weak var mEmail: UILabel!
    
    @IBOutlet weak var mPassword: UILabel!
    
    @IBOutlet weak var mCopy: UIImageView!
    
    @IBOutlet weak var mView: UIView!
    
    @IBOutlet weak var dashboardBtn: UIButton!
    var b2bModel : B2BModel?
    override func viewDidLoad() {
        
        guard let b2bModel = b2bModel else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        mEmail.text = b2bModel.email ?? "ERROR"
        mPassword.text = b2bModel.password ?? "Password"
        mView.layer.cornerRadius = 8
    
        dashboardBtn.layer.cornerRadius = 8
        
        mCopy.isUserInteractionEnabled = true
        mCopy.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(copyBtnClicked)))
        
        
    }
    
    @objc func copyBtnClicked(){
        self.showToast(message: "Copied")
        UIPasteboard.general.string = "Full Name - \(b2bModel!.name ?? "")\n\nEmail - \(b2bModel!.email ?? "")\n\nPassword - \(b2bModel!.password ?? "")"
       
    }
    
    @IBAction func dashboardBtnClicked(_ sender: Any) {
        self.beRootScreen(mIdentifier: Constants.StroyBoard.franchiseTabbarViewController)
    }
}
