//
//  BusinessDashboardViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 26/05/23.
//

import UIKit
import SDWebImage

class BusinessDashboardViewController : UIViewController {
    
    @IBOutlet weak var mProfile: UIImageView!
    @IBOutlet weak var totalOfferView: UIView!
    
    @IBOutlet weak var totalOffersCount: UILabel!
    @IBOutlet weak var mView: UIView!

    @IBOutlet weak var businessName: UILabel!
    @IBOutlet weak var businessAbout: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var openingTime: UILabel!
    @IBOutlet weak var closingTime: UILabel!
    @IBOutlet weak var daysLeft: UILabel!
    
    
    override func viewDidLoad() {
        
        guard let businessModel = B2BModel.data else {
            
            DispatchQueue.main.async {
                self.logout()
            }
            return
            
        }
        mProfile.makeRounded()
        if let path = businessModel.image, !path.isEmpty {
            mProfile.sd_setImage(with: URL(string: path), placeholderImage: UIImage(named: "profile-placeholder"))
        }
        
        totalOfferView.layer.cornerRadius = 8
        mView.layer.cornerRadius = 8
        
        let iDaysLeft = self.membershipDaysLeft(currentDate: Constants.currentDate, expireDate: businessModel.expiryDate ?? Date())
        daysLeft.text = "\(iDaysLeft)"
        if iDaysLeft > 60 {
            daysLeft.textColor = UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 1)
        }
        else {
            daysLeft.textColor = UIColor(red: 1, green: 0, blue: 0 , alpha: 1)
        }
        
        businessName.text = businessModel.name ?? ""
        businessAbout.text = businessModel.aboutBusiness ?? ""
        address.text = businessModel.address ?? ""
        openingTime.text = self.convertDateIntoTimeForRecurringVoucher(businessModel.openingTime ?? Date())
        closingTime.text = self.convertDateIntoTimeForRecurringVoucher(businessModel.closingTime ?? Date())
        
        mView.isUserInteractionEnabled = true
        mView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(businessViewClicked)))
    }
    
    
    
    @objc func businessViewClicked(){
        performSegue(withIdentifier: "showBusinessDetailsSeg", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBusinessDetailsSeg" {
            if let VC = segue.destination as? BusinessDetailsViewController {
                VC.b2bModel = B2BModel.data
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
     
        getB2BVouchersCount(by: B2BModel.data!.uid ?? "123") { count in
            self.totalOffersCount.text = "\(count)"
        }
    }
    
}
