//
//  RedeemHistoryViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 09/05/23.
//

import UIKit

class RedeemHistoryViewController : UIViewController {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var no_historyAvailable: UILabel!
    var redeemHistoryModels = Array<RedeemHistoryModel>()
    override func viewDidLoad() {
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        ProgressHUDShow(text: "")
        getRedeemHistory(userId: UserModel.data!.uid ?? "123") { redeemHistoryModels, error in
            self.ProgressHUDHide()
            if let redeemHistoryModels = redeemHistoryModels {
                self.redeemHistoryModels.removeAll()
                self.redeemHistoryModels.append(contentsOf: redeemHistoryModels)
                self.tableView.reloadData()
            }
        }
        
       
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
    }
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    @objc func cellClicked(gest : MyGesture){
      
    }
    
}
extension RedeemHistoryViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.no_historyAvailable.isHidden = redeemHistoryModels.count > 0 ? true : false
        return redeemHistoryModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "redeemCell", for: indexPath) as? OfferRedeemTableViewCell {
            
            let voucherModel = redeemHistoryModels[indexPath.row]
           
            cell.mView.layer.cornerRadius = 8
            cell.mTitle.text = voucherModel.voucherTitle ?? ""
            cell.mConditions.text = voucherModel.voucherConditions ?? ""
            if let isFree = voucherModel.isFree, isFree {
                cell.freeLabel.text = "FREE"
            }
            else {
                cell.freeLabel.text = "OFF"
            }
            cell.mProfile.layer.cornerRadius = 4
            cell.time.text = self.convertDateForVoucher(voucherModel.date ?? Date())
            
            if let path = voucherModel.voucherImage, !path.isEmpty {
                cell.mProfile.sd_setImage(with: URL(string: path), placeholderImage: UIImage(named: "placeholder"))
            }
            
            
            cell.freeView.layer.cornerRadius = 4
            
            cell.mView.isUserInteractionEnabled = true
            let gest = MyGesture(target: self, action: #selector(cellClicked(gest: )))
            gest.index = indexPath.row
            cell.addGestureRecognizer(gest)
            
         
            return cell
        }
        return OfferRedeemTableViewCell()
    }
    
    
    
    
    
    
}
