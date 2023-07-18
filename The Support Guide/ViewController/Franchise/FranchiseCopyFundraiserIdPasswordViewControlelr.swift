//
//  FranchiseCopyFundraiserIdPasswordViewControlelr.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 21/05/23.
//

import UIKit

class FranchiseCopyFundraiserIdPasswordViewControlelr : UIViewController {
    
    
    @IBOutlet weak var mEmail: UILabel!
    
    @IBOutlet weak var mPassword: UILabel!
    
    @IBOutlet weak var mCopy: UIImageView!
    
    @IBOutlet weak var mView: UIView!
    
    @IBOutlet weak var dashboardBtn: UIButton!
    var fundraiserModel : FundraiserModel?
    override func viewDidLoad() {
        
        guard let fundraiserModel = fundraiserModel else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        mEmail.text = fundraiserModel.email ?? "ERROR"
        mPassword.text = fundraiserModel.password ?? "Password"
        mView.layer.cornerRadius = 8
    
        dashboardBtn.layer.cornerRadius = 8
        
        mCopy.isUserInteractionEnabled = true
        mCopy.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(copyBtnClicked)))
        
        
    }
    
    @objc func copyBtnClicked(){
        self.showToast(message: "Copied")
        UIPasteboard.general.string = "Full Name - \(fundraiserModel!.name ?? "")\n\nEmail - \(fundraiserModel!.email ?? "")\n\nPassword - \(fundraiserModel!.password ?? "")"
       
    }
    
    @IBAction func dashboardBtnClicked(_ sender: Any) {
        self.beRootScreen(mIdentifier: Constants.StroyBoard.franchiseTabbarViewController)
    }
}
