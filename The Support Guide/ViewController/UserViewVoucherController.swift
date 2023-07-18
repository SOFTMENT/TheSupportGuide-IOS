//
//  UserViewVoucherController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 12/06/23.
//

import UIKit

class UserViewVoucherController : UIViewController {
    
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var mProfile: UIImageView!
    @IBOutlet weak var businessName: UILabel!
    @IBOutlet weak var businessCatName: UILabel!

    @IBOutlet weak var mTitle: UILabel!
    @IBOutlet weak var offFreeLabel: UILabel!
    @IBOutlet weak var redeemLeft: UILabel!
    @IBOutlet weak var validUntil: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var conditions: UILabel!
    @IBOutlet weak var redeemBtn: UIButton!
    var totalLeftCount = 0
    var businessModel : B2BModel?
    var voucherModel : VoucherModel?
    override func viewDidLoad() {
        
        guard let voucherModel = voucherModel,
              let businessModel = businessModel else {
            
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            
            return
            
        }
        
        redeemBtn.layer.cornerRadius = 8
        mProfile.layer.cornerRadius = 8
        
        if let path = businessModel.image, !path.isEmpty {
            mProfile.sd_setImage(with: URL(string: path), placeholderImage: UIImage(named: "placeholder"))
        }
        
        businessName.text = businessModel.name ?? ""
        businessCatName.text = businessModel.catName ?? ""
        
        mTitle.text = voucherModel.title ?? ""
        
        if let isFree = voucherModel.isFree, isFree {
            offFreeLabel.isHidden = true
        }
        else {
            offFreeLabel.text = "Get\(voucherModel.discounts ?? 0)% OFF"
        }
        
        validUntil.text = "Valid until \(convertDateFormaterWithoutDash(voucherModel.valid ?? Date()))"
        
        address.text = businessModel.address ?? ""
        conditions.text = voucherModel.conditions ?? ""
        
        backView.isUserInteractionEnabled = true
        backView.layer.cornerRadius = 8
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        backView.dropShadow()
        
        
        
        if let times = voucherModel.timesRedeemable, times > 0 {
            self.redeemLeft.text = "\(times)"
            if !FirebaseStoreManager.auth.currentUser!.isAnonymous {
                let query = FirebaseStoreManager.db.collection("RedeemHistory").whereField("voucherId", isEqualTo: voucherModel.id ?? "123").whereField("userId", isEqualTo: UserModel.data!.uid ?? "123")
                let countQuery = query.count
                
                    countQuery.getAggregation(source: .server) { snapshot, error in
                        if let snapshot = snapshot{
                            self.totalLeftCount = times - Int(truncating: snapshot.count)
                            self.redeemLeft.text = "\(self.totalLeftCount)"
                        }
                        else {
                            self.totalLeftCount = times
                            self.redeemLeft.text = "\(self.totalLeftCount)"
                        }
                        
                    }
            }
          
        }
        else {
            self.totalLeftCount = -1
            self.redeemLeft.text = "UNLIMITED"
        }
    }
    
    @IBAction func redeemBtnClicked(_ sender: Any) {
        
        if FirebaseStoreManager.auth.currentUser!.isAnonymous {
            self.beRootScreen(mIdentifier: Constants.StroyBoard.signInViewController)
        }
        else {
            if totalLeftCount == -1  || totalLeftCount > 0{
                
                let alert = UIAlertController(title: nil, message: "Please be sure you can show this to vendor for redemption ", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Continue", style: .default,handler: { action in
                    let redeemHistory = RedeemHistoryModel()
                    redeemHistory.date = Date()
                    redeemHistory.voucherConditions = self.voucherModel!.conditions
                    redeemHistory.voucherTitle = self.voucherModel!.title
                    redeemHistory.voucherImage = self.voucherModel!.mImage
                    redeemHistory.voucherId = self.voucherModel!.id
                    redeemHistory.userId = UserModel.data!.uid
                    redeemHistory.b2bId = self.businessModel!.uid
                    redeemHistory.isFree = self.voucherModel!.isFree
                    let collectionRef = FirebaseStoreManager.db.collection("RedeemHistory")
                    let id = collectionRef.document().documentID
                    redeemHistory.id = id
                    let batch = FirebaseStoreManager.db.batch()
                    try! batch.setData(from: redeemHistory, forDocument: collectionRef.document(id))
                    
                    self.ProgressHUDShow(text: "")
                    batch.commit { error in
                        self.ProgressHUDHide()
                        if let error = error {
                            self.showError(error.localizedDescription)
                        }
                        else {
                            self.performSegue(withIdentifier: "voucherRedeemSuccessSeg", sender: nil)
                        }
                    }
                    
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                present(alert, animated: true)
                
            }
            
            else {
                self.showToast(message: "You have reached maximum limit.")
            }
            
            
        }
    }
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    
}
