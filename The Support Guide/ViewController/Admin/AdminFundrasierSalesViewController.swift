//
//  AdminFundrasierSalesViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 11/06/23.
//

import UIKit

class AdminFundrasierSalesViewController : UIViewController  {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var fundraiserModels = Array<FundraiserModel>()
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
        
        getAllFundraiserBy(franchiseId: franchiseId) { fundraiserModels, error in
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                }
                else {
                    
                        self.fundraiserModels.removeAll()
                        self.fundraiserModels.append(contentsOf: fundraiserModels ?? [])
                        self.tableView.reloadData()
                    
                }
            }
        }
        
       
    }
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
    @objc func cellClicked(value : MyGesture){

            performSegue(withIdentifier: "admin_SalesMemberSeg", sender: value.id)
        
  
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "admin_SalesMemberSeg" {
            if let VC = segue.destination as? AdminSalesMemberViewController {
                if let id  = sender as? String {
                    VC.fundrasierId = id
                }
            }
        }
    }
    
}

extension AdminFundrasierSalesViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        noBusinessesSaleAvailable.isHidden = fundraiserModels.count > 0 ? true : false
        return fundraiserModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "fundraiserCellCell", for: indexPath) as? FundraiserSalesTableViewCell {
            let fundraiserModel = fundraiserModels[indexPath.row]
            cell.mView.layer.cornerRadius = 8
            cell.mAmountView.layer.cornerRadius = 4
          
            cell.mProfile.layer.cornerRadius = 8
           
            cell.mAmount.text = "$\(fundraiserModel.totalEarning ?? 0)"
        
            
            if let path = fundraiserModel.image, !path.isEmpty {
                cell.mProfile.sd_setImage(with: URL(string: path), placeholderImage: UIImage(named: "profile-placeholder"))
            }
            cell.mAddress.text = fundraiserModel.address ?? ""
            cell.mName.text = fundraiserModel.name ?? ""
            
            let mGest = MyGesture(target: self, action: #selector(self.cellClicked(value: )))
            mGest.id = fundraiserModel.uid ?? "123"
            cell.mView.isUserInteractionEnabled = true
            cell.addGestureRecognizer(mGest)
            
         
            
            return cell
        }
        return FundraiserSalesTableViewCell()
    }
    
    
}
