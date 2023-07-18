//
//  FranchiseB2BViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 20/05/23.
//

import UIKit

class FranchiseB2BViewController : UIViewController {
    
    @IBOutlet weak var addView: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noBusinessesAvailable: UILabel!
    @IBOutlet weak var searchB2bTF: UITextField!
    
    var b2bModels = Array<B2BModel>()
    override func viewDidLoad() {
        
        
        tableView.dataSource = self
        tableView.delegate = self
        
        searchB2bTF.delegate = self
        searchB2bTF.setLeftIcons(icon: UIImage(named: "search-6")!)
        
        addView.isUserInteractionEnabled = true
        addView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addViewClicked)))
        
        getBusinesses(by: FranchiseModel.data!.uid ?? "123") { b2bModels, error in
            if let error = error {
                self.showError(error)
            }
            else {
                self.b2bModels.removeAll()
                self.b2bModels.append(contentsOf: b2bModels ?? [])
                self.tableView.reloadData()
            }
        }
    }
    
  
    @objc func addViewClicked(){
        self.performSegue(withIdentifier: "addB2bSeg", sender: nil)
    }
    
    @objc func cellClicked(gest : MyGesture){
        performSegue(withIdentifier: "franchiseShowB2BSeg", sender: self.b2bModels[gest.index])
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "franchiseShowB2BSeg" {
            if let VC = segue.destination as? FranchiseB2BDetailsViewController {
                if let b2bModel = sender as? B2BModel {
                    VC.b2bModel = b2bModel
                }
            }
        }
    }
}

extension FranchiseB2BViewController : UITextFieldDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}

extension FranchiseB2BViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.noBusinessesAvailable.isHidden = b2bModels.count > 0 ? true : false
        return b2bModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "b2bFundraiserCell", for: indexPath) as? B2bFundraiserTableViewCell {
            
            cell.mView.layer.cornerRadius = 8
            cell.mView.isUserInteractionEnabled = true
            let mGest = MyGesture(target: self, action: #selector(cellClicked(gest:)))
            mGest.index = indexPath.row
            cell.mView.addGestureRecognizer(mGest)
            
            cell.mImage.layer.cornerRadius = 4
            cell.typeView.layer.cornerRadius = 3
            
            let b2bModel = b2bModels[indexPath.row]
            
            if let path = b2bModel.image , !path.isEmpty {
                cell.mImage.sd_setImage(with: URL(string: path), placeholderImage: UIImage(named: "placeholder"))
            }
            cell.mName.text = b2bModel.name ?? "Name"
            cell.mAddress.text = b2bModel.address ?? "Address"
            cell.openingTime.text = self.convertDateIntoTimeForRecurringVoucher(b2bModel.openingTime ?? Date())
            cell.closingTime.text = self.convertDateIntoTimeForRecurringVoucher(b2bModel.closingTime ?? Date())
            
            let iDaysLeft = self.membershipDaysLeft(currentDate: Constants.currentDate, expireDate: b2bModel.expiryDate ?? Date())
            cell.daysLeft.text = "\(iDaysLeft)"
            if iDaysLeft > 60 {
                cell.daysLeft.textColor = UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 1)
            }
            else {
                cell.daysLeft.textColor = UIColor(red: 1, green: 0, blue: 0 , alpha: 1)
            }
            
         
            
            
            return cell
        }
        return B2bFundraiserTableViewCell()
    }
    
    
    
}
