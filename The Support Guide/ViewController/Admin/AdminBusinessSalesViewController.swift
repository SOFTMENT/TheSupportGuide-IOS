//
//  BusinessSalesViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 11/06/23.
//

import UIKit

class AdminBusinessSalesViewController : UIViewController  {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var businessSaleModels = Array<BusinessTransactionModel>()
    @IBOutlet weak var noBusinessesSaleAvailable: UILabel!
    var franchiseId : String?
    override func viewDidLoad() {
        
        guard let franchiseId = franchiseId else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        tableView.delegate = self
        tableView.dataSource = self
        
        ProgressHUDShow(text: "")
        getAllBusinessTransactionsBy(franchiseId: franchiseId) { businessSaleModels, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                
                    self.businessSaleModels.removeAll()
                    self.businessSaleModels.append(contentsOf: businessSaleModels ?? [])
                    self.tableView.reloadData()
                
            }
        }
    }
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
    @objc func cellClicked(value : MyGesture){
        if let b2bModel = value.b2bModel {
            performSegue(withIdentifier: "admin_b2bDetailsSeg", sender: value.b2bModel)
        }
  
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "admin_b2bDetailsSeg" {
            if let VC = segue.destination as? BusinessDetailsViewController {
                if let b2bModel = sender as? B2BModel {
                    VC.b2bModel = b2bModel
                    VC.fromAdminPanel = true
                }
            }
        }
    }
    
}

extension AdminBusinessSalesViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        noBusinessesSaleAvailable.isHidden = businessSaleModels.count > 0 ? true : false
        return businessSaleModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "businessSalecCell", for: indexPath) as? BusinessSaleTableViewCell {
            let businessSaleModel = businessSaleModels[indexPath.row]
            cell.mView.layer.cornerRadius = 8
            cell.mAmountView.layer.cornerRadius = 4
            cell.mJoinView.layer.cornerRadius = 4
            cell.mProfile.layer.cornerRadius = 8
            if businessSaleModel.type == "J" {
                cell.mJoin.text = "Joining Fee"
            }
            else{
                cell.mJoin.text = "RENEW Fee"
            }
            
            cell.mAmount.text = "$\(businessSaleModel.amount ?? 0)"
            cell.mDate.text = convertDateAndTimeFormater(businessSaleModel.date ?? Date())
            
            self.getBusinessBy(uid: businessSaleModel.businessId ?? "123") { b2bModel in
                if let b2bModel = b2bModel {
                    if let path = b2bModel.image, !path.isEmpty {
                        cell.mProfile.sd_setImage(with: URL(string: path), placeholderImage: UIImage(named: "profile-placeholder"))
                    }
                    cell.mAddress.text = b2bModel.address ?? ""
                    cell.mName.text = b2bModel.name ?? ""
                    
                    let mGest = MyGesture(target: self, action: #selector(self.cellClicked(value: )))
                    mGest.b2bModel = b2bModel
                    cell.mView.isUserInteractionEnabled = true
                    cell.addGestureRecognizer(mGest)
                }

            }
            
            
            return cell
        }
        return BusinessSaleTableViewCell()
    }
    
    
}
