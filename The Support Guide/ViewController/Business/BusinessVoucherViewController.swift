//
//  BusinessVoucherViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 29/05/23.
//

import UIKit

class BusinessVoucherViewController : UIViewController {
    
 
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noVouchersAvailable: UILabel!
    @IBOutlet weak var addView: UIImageView!
    var voucherModels = Array<VoucherModel>()
    
    override func viewDidLoad() {
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        addView.isUserInteractionEnabled = true
        addView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addViewClicked)))
        
        ProgressHUDShow(text: "")
        getAllVouchers(by: B2BModel.data!.uid ?? "123") { voucherModels, error in
            self.ProgressHUDHide()
            if let voucherModels = voucherModels {
                self.voucherModels.removeAll()
                self.voucherModels.append(contentsOf: voucherModels)
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func cellClicked(gest : MyGesture){
        self.performSegue(withIdentifier: "editVoucherSeg", sender: voucherModels[gest.index])
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editVoucherSeg" {
            if let VC = segue.destination as? BusinessEditVoucherViewController {
                if let voucherModel = sender as? VoucherModel {
                    VC.voucherModel = voucherModel
                }
            }
        }
    }
    
    @objc func addViewClicked(){
        self.performSegue(withIdentifier: "addVoucherSeg", sender: nil)
    }
}

extension BusinessVoucherViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.noVouchersAvailable.isHidden = voucherModels.count > 0 ? true : false
        return voucherModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "voucherCell", for: indexPath) as? VoucherTableViewCell {
            
            let voucherModel = voucherModels[indexPath.row]
           
            cell.mView.layer.cornerRadius = 8
            cell.mTitle.text = voucherModel.title ?? ""
            cell.mConditions.text = voucherModel.conditions ?? ""
            if let isFree = voucherModel.isFree, isFree {
                cell.freeLabel.text = "FREE"
            }
            else {
                cell.freeLabel.text = "OFF"
            }
            cell.mProfile.layer.cornerRadius = 4
            
            if let path = voucherModel.mImage, !path.isEmpty {
                cell.mProfile.sd_setImage(with: URL(string: path), placeholderImage: UIImage(named: "placeholder"))
            }
            
            
            cell.freeView.layer.cornerRadius = 4
            
            cell.mView.isUserInteractionEnabled = true
            let gest = MyGesture(target: self, action: #selector(cellClicked(gest: )))
            gest.index = indexPath.row
            cell.addGestureRecognizer(gest)
            
            return cell
        }
        return VoucherTableViewCell()
    }
    
    
    
    
    
    
}
