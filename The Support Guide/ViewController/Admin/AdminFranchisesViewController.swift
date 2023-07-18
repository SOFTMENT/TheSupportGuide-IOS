//
//  AdminFranchisesViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 12/05/23.
//

import UIKit

class AdminFranchisesViewController : UIViewController {
    
    @IBOutlet weak var totalSalesCount: UILabel!
    @IBOutlet weak var totalFranchiseCount: UILabel!
    @IBOutlet weak var totalSalesView: UIView!
    @IBOutlet weak var totoalFranchiseView: UIView!
    @IBOutlet weak var noFranAvailable: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addFran: UIImageView!
    var franchiseModels  = Array<FranchiseModel>()
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        addFran.isUserInteractionEnabled = true
        addFran.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addViewClicked)))
        
        self.ProgressHUDShow(text: "")
        self.getAllFranchises { franchiseModels, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error)
            }
            else {
                
                self.franchiseModels.removeAll()
                self.franchiseModels.append(contentsOf: franchiseModels!)
                self.totalFranchiseCount.text = "\(self.franchiseModels.count)"
                
                var earn = 0
                for franchiseModel in self.franchiseModels {
                    earn = earn + (franchiseModel.totalBusinessEarning ?? 0) + (franchiseModel.totalFundraiserEarning ?? 0)
                }
                self.totalSalesCount.text =  "$\(earn)"
                
                self.tableView.reloadData()
            }
        }
        
        totalSalesView.layer.cornerRadius = 8
        totoalFranchiseView.layer.cornerRadius = 8
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewFranchiseSeg" {
            if let VC = segue.destination as? AdminViewFranchiseProfileViewController {
                if let franchiseModel = sender as? FranchiseModel {
                    VC.franchiseModel = franchiseModel
                }
            }
        }
    }
    
    @objc func cellClicked(value : MyGesture){
        performSegue(withIdentifier: "viewFranchiseSeg", sender: franchiseModels[value.index])
    }
    
    @objc func addViewClicked(){
        performSegue(withIdentifier: "addFranSeg", sender: nil)
    }
}

extension AdminFranchisesViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.noFranAvailable.isHidden = franchiseModels.count > 0 ? true : false
        
        return franchiseModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "franchiseCell", for: indexPath) as? FranchiseViewTableView {
            
            let franchiseModel = franchiseModels[indexPath.row]
            cell.franchiseView.layer.cornerRadius = 8
            
            cell.franchiseName.text = franchiseModel.name ?? ""
            cell.franchiseLocation.text = franchiseModel.address ?? ""
            
            cell.franchiseView.isUserInteractionEnabled = true
            let myGest = MyGesture(target: self, action: #selector(cellClicked))
            myGest.index = indexPath.row
            cell.franchiseView.addGestureRecognizer(myGest)
            return cell
        }
        return FranchiseViewTableView()
    }
    
    
    
    
}
