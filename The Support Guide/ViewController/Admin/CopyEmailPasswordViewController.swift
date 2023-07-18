//
//  CopyEmailPasswordViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 18/05/23.
//

import UIKit

class CopyEmailPasswordViewController : UIViewController {
    
    
    @IBOutlet weak var mEmail: UILabel!
    
    @IBOutlet weak var mPassword: UILabel!
    
    @IBOutlet weak var mCopy: UIImageView!
    
    @IBOutlet weak var mView: UIView!
    
    @IBOutlet weak var dashboardBtn: UIButton!
    var franchiseModel : FranchiseModel?
    override func viewDidLoad() {
        
        guard let franchiseModel = franchiseModel else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        mEmail.text = franchiseModel.email ?? "ERROR"
        mPassword.text = franchiseModel.password ?? "Password"
        mView.layer.cornerRadius = 8
    
        dashboardBtn.layer.cornerRadius = 8
        
        mCopy.isUserInteractionEnabled = true
        mCopy.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(copyBtnClicked)))
        
        
    }
    
    @objc func copyBtnClicked(){
        self.showToast(message: "Copied")
        UIPasteboard.general.string = "Full Name - \(franchiseModel!.name ?? "")\n\nEmail - \(franchiseModel!.email ?? "")\n\nPassword - \(franchiseModel!.password ?? "")"
       
    }
    
    @IBAction func dashboardBtnClicked(_ sender: Any) {
        self.beRootScreen(mIdentifier: Constants.StroyBoard.adminTabBarViewController)
    }
}
