//
//  FranchiseFundraiserViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 21/05/23.
//

import UIKit

class FranchiseFundraiserViewController : UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addView: UIImageView!
    @IBOutlet weak var noFundraiserAvailable: UILabel!
    
    @IBOutlet weak var searchB2bTF: UITextField!
    var fundraiserModels = Array<FundraiserModel>()
    override func viewDidLoad() {
        
        
        tableView.dataSource = self
        tableView.delegate = self
        
        searchB2bTF.delegate = self
        searchB2bTF.setLeftIcons(icon: UIImage(named: "search-6")!)
        
        addView.isUserInteractionEnabled = true
        addView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addViewClicked)))
        
        getFundraisers(by: FranchiseModel.data!.uid ?? "123") { fundraiserModels, error in
            if let error = error {
                self.showError(error)
            }
            else {
                self.fundraiserModels.removeAll()
                self.fundraiserModels.append(contentsOf: fundraiserModels ?? [])
                self.tableView.reloadData()
            }
        }
    }
 
    @objc func addViewClicked(){
        self.performSegue(withIdentifier: "addFundraiserSeg", sender: nil)
    }
    
    @objc func cellClicked(gest : MyGesture){
        self.performSegue(withIdentifier: "editFundraiserSeg", sender: self.fundraiserModels[gest.index])
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editFundraiserSeg" {
            if let VC = segue.destination as? FranchiseEditFundraiserViewController {
                if let fundModel = sender as? FundraiserModel {
                    VC.fundraiserModel = fundModel
                }
            }
        }
    }
}

extension FranchiseFundraiserViewController : UITextFieldDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}

extension FranchiseFundraiserViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.noFundraiserAvailable.isHidden = fundraiserModels.count > 0 ? true : false
        return fundraiserModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "b2bFundraiserCell", for: indexPath) as? B2bFundraiserTableViewCell {
            
            cell.mView.layer.cornerRadius = 8
            cell.mImage.layer.cornerRadius = 4
            cell.typeView.layer.cornerRadius = 3
            
            let b2bModel = fundraiserModels[indexPath.row]
            
            if let path = b2bModel.image , !path.isEmpty {
                cell.mImage.sd_setImage(with: URL(string: path), placeholderImage: UIImage(named: "placeholder"))
            }
            cell.mName.text = b2bModel.name ?? "Name"
            cell.mAddress.text = b2bModel.address ?? "Address"
            cell.phoneNumber.text = b2bModel.phoneNumber ?? "Phone Number"
            
            cell.mView.isUserInteractionEnabled = true
            let myGest = MyGesture(target: self, action: #selector(cellClicked(gest: )))
            myGest.index = indexPath.row
            cell.addGestureRecognizer(myGest)
            
            return cell
        }
        return B2bFundraiserTableViewCell()
    }
    
    
    
}
