//
//  FranchiseDashboardViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 20/05/23.
//

import UIKit

class FranchiseDashboardViewController : UIViewController {
    
    
    @IBOutlet weak var fundraiserAccountCount: UILabel!
    @IBOutlet weak var b2bAccountCount: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var businessView: UIView!
    @IBOutlet weak var fundraiserView: UIView!
    @IBOutlet weak var noRecentAccountsFound: UILabel!
    @IBOutlet weak var businessImageView: UIView!
    @IBOutlet weak var fundRaiserImageView: UIView!
    @IBOutlet weak var b2bTotalSales: UILabel!
    @IBOutlet weak var fundraiserTotalSales: UILabel!
    
    var recenAddedModels = Array<RecentlyAddedModel>()
    override func viewDidLoad() {
        
        guard let franchiseModel = FranchiseModel.data else {
            
            DispatchQueue.main.async {
                self.logout()
            }
            return
            
        }
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        businessImageView.layer.cornerRadius = businessImageView.bounds.height / 2
        fundRaiserImageView.layer.cornerRadius =  fundRaiserImageView.bounds.height / 2
        
        businessView.layer.cornerRadius = 8
        fundraiserView.layer.cornerRadius = 8
        
        businessView.isUserInteractionEnabled = true
        businessView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(businessViewClicked)))
        
        fundraiserView.isUserInteractionEnabled = true
        fundraiserView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(fundraiserViewClicked)))
        
        profilePic.makeRounded()
        
        fundraiserTotalSales.text = "$\(franchiseModel.totalFundraiserEarning ?? 0)"
        b2bTotalSales.text = "$\(franchiseModel.totalBusinessEarning ?? 0)"
        
        if let mProfile = franchiseModel.image, !mProfile.isEmpty {
            profilePic.sd_setImage(with: URL(string: mProfile), placeholderImage: UIImage(named: "profile-placeholder"))
        }
        
        getAllRecentsB2BAndSales(franchiseId: FranchiseModel.data!.uid ?? "123") { recenAddedModels, error in
            if let error = error {
                self.showError(error)
            }
            else{
                self.recenAddedModels.removeAll()
                self.recenAddedModels.append(contentsOf: recenAddedModels ?? [])
                self.tableView.reloadData()
                
            }
        }
    }
    
    @objc func businessViewClicked(){
        performSegue(withIdentifier: "adminBusinessSaleSeg", sender: nil)
    }
    
    @objc func fundraiserViewClicked(){
        performSegue(withIdentifier: "adminFundraiserSaleSeg", sender: nil)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        getB2BAccountsCount(by: FranchiseModel.data!.uid ?? "123") { count in
            self.b2bAccountCount.text = "\(count)"
        }
        
        getFundraiserAccountsCount(by: FranchiseModel.data!.uid ?? "123") { count in
            self.fundraiserAccountCount.text = "\(count)"
        }
        
    }
    
    @objc func b2bClicked(value : MyGesture){
        
        performSegue(withIdentifier: "dashboardfranchiseShowB2BSeg", sender: value.b2bModel!)
    }
    
    @objc func fundraiserClicked(value : MyGesture){
        performSegue(withIdentifier: "dashboardeditFundraiserSeg", sender: value.fundraiserModel!)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dashboardfranchiseShowB2BSeg" {
            if let VC = segue.destination as? FranchiseB2BDetailsViewController {
                if let b2bModel = sender as? B2BModel {
                    VC.b2bModel = b2bModel
                }
            }
        }
        else if segue.identifier == "dashboardeditFundraiserSeg" {
            if let VC = segue.destination as? FranchiseEditFundraiserViewController {
                if let fundModel = sender as? FundraiserModel {
                    VC.fundraiserModel = fundModel
                }
            }
        }
        else if segue.identifier == "adminBusinessSaleSeg" {
            if let VC = segue.destination as? AdminBusinessSalesViewController {
                VC.franchiseId = FranchiseModel.data!.uid
            }
        }
        else if segue.identifier == "adminFundraiserSaleSeg" {
            if let VC = segue.destination as? AdminFundrasierSalesViewController {
                VC.franchiseId = FranchiseModel.data!.uid
            }
        }
    }
    
    
    
}

extension FranchiseDashboardViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.noRecentAccountsFound.isHidden = recenAddedModels.count > 0 ? true : false
        return recenAddedModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "b2bFundraiserCell", for: indexPath) as? B2bFundraiserTableViewCell {
            
            cell.mView.layer.cornerRadius = 8
            cell.mImage.layer.cornerRadius = 4
            cell.typeView.layer.cornerRadius = 3
            
            let recentModel = recenAddedModels[indexPath.row]
            
          
            self.getB2bAndFundraiser(by: recentModel.uid ?? "123", franchiseId: FranchiseModel.data!.uid ?? "123", type: recentModel.type! == "b2b" ? "Businesses" : "Fundraisers") { businessModel, fundrasierModel, error in
                
                if error == error {
                    self.recenAddedModels.remove(at: indexPath.row)
                    self.tableView.reloadData()
                }
                else {
                    if let businessModel = businessModel{
                        if let path = businessModel.image , !path.isEmpty {
                            cell.mImage.sd_setImage(with: URL(string: path), placeholderImage: UIImage(named: "placeholder"))
                        }

                        cell.mName.text = businessModel.name ?? "Name"
                        cell.mAddress.text = businessModel.address ?? "Address"
                        cell.phoneNumber.text = businessModel.phoneNumber ?? "Phone Number"
                        cell.type.text = "B2B"
                        
                        cell.mView.isUserInteractionEnabled = true
                        let b2bGest = MyGesture(target: self, action: #selector(self.b2bClicked(value: )))
                        b2bGest.b2bModel = businessModel
                        cell.mView.addGestureRecognizer(b2bGest)
                    }
                else if let fundrasierModel = fundrasierModel {
                    if let path = fundrasierModel.image , !path.isEmpty {
                        cell.mImage.sd_setImage(with: URL(string: path), placeholderImage: UIImage(named: "placeholder"))
                    }

                    cell.mName.text = fundrasierModel.name ?? "Name"
                    cell.mAddress.text = fundrasierModel.address ?? "Address"
                    cell.phoneNumber.text = fundrasierModel.phoneNumber ?? "Phone Number"
                    cell.type.text = "SALES"
                    
                    cell.mView.isUserInteractionEnabled = true
                    let fundGest = MyGesture(target: self, action: #selector(self.fundraiserClicked(value: )))
                    fundGest.fundraiserModel = fundrasierModel
                    cell.mView.addGestureRecognizer(fundGest)
                }
                }
               
                }
            
            return cell
        }
        return B2bFundraiserTableViewCell()
    }
    
    
    
}
