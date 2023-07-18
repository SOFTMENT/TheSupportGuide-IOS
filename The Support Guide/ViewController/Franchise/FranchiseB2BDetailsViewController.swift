//
//  FranchiseB2BDetailsViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 10/06/23.
//

import UIKit
import MapKit

class FranchiseB2BDetailsViewController : UIViewController {
    
    @IBOutlet weak var daysLeft: UILabel!
    @IBOutlet weak var extendBtn: UIButton!
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var mProfile: UIImageView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var businessName: UILabel!
    @IBOutlet weak var businessEmail: UILabel!
    @IBOutlet weak var businessPhone: UILabel!
    @IBOutlet weak var businessLocation: UILabel!
    @IBOutlet weak var openingTime: UILabel!
    @IBOutlet weak var closingTime: UILabel!
    @IBOutlet weak var aboutBusiness: UILabel!
    var storeModels = Array<StoreModel>()
    var b2bModel : B2BModel?
    override func viewDidLoad() {
        
      
    
        
        extendBtn.layer.cornerRadius = 8
        
        editBtn.layer.cornerRadius = 6
        editBtn.dropShadow()
    
        mProfile.layer.cornerRadius = 8
      
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
    }
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let b2bModel = b2bModel else {
            
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        let iDaysLeft = self.membershipDaysLeft(currentDate: Constants.currentDate, expireDate: b2bModel.expiryDate ?? Date())
           daysLeft.text = "\(iDaysLeft)"
        if iDaysLeft > 60 {
            daysLeft.textColor = UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 1)
        }
        else {
            daysLeft.textColor = UIColor(red: 1, green: 0, blue: 0 , alpha: 1)
        }
        
        if let path = b2bModel.image, !path.isEmpty {
            mProfile.sd_setImage(with: URL(string: path), placeholderImage: UIImage(named: "profile-placeholder"))
        }
        
        businessName.text = b2bModel.name ?? ""
        businessEmail.text = b2bModel.email ?? ""
        businessPhone.text = b2bModel.phoneNumber ?? ""
        businessLocation.text = b2bModel.address ?? ""
        
        openingTime.text = self.convertDateIntoTimeForRecurringVoucher(b2bModel.openingTime ?? Date())
        closingTime.text = self.convertDateIntoTimeForRecurringVoucher(b2bModel.closingTime ?? Date())
        
        aboutBusiness.text = b2bModel.aboutBusiness ?? ""
    }
 
    
    @IBAction func extendBtnClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Extend 1 Year", message: "Please select payment method", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Debit / Credit Card", style: .default,handler: { action in
            
        }))
        alert.addAction(UIAlertAction(title: "Apple Pay", style: .default,handler: { action in
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func checkOut(paymentMethod : String){
    
    }
    
    @IBAction func editBtnClicked(_ sender: Any) {
        performSegue(withIdentifier: "franchise_editBusinessSeg", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "franchise_editBusinessSeg" {
            if let VC = segue.destination as? FranchiseEditBusinessController {
                VC.b2bModel = b2bModel
            }
        }
       
    }
    

 
    
  
}

