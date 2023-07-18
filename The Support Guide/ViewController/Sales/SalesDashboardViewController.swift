//
//  SalesDashboardViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 31/05/23.
//

import UIKit

class SalesDashboardViewController : UIViewController {
    
    @IBOutlet weak var noRecentActivityAvailable: UILabel!
    @IBOutlet weak var mProfile: UIImageView!
    @IBOutlet weak var totalSalesView: UIView!
    @IBOutlet weak var totalEarningsView: UIView!
    @IBOutlet weak var totalSalesImageView: UIView!
    @IBOutlet weak var totalEarningsImageView: UIView!
    @IBOutlet weak var totalSalesCount: UILabel!
    @IBOutlet weak var totalEarningCount: UILabel!
    var memberModels = Array<SalesMemberModel>()
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        mProfile.layer.cornerRadius = 8
        totalSalesView.layer.cornerRadius = 8
        totalEarningsView.layer.cornerRadius = 8
        totalSalesImageView.layer.cornerRadius = 8
        totalEarningsImageView.layer.cornerRadius = 8

        if let path = FundraiserModel.data!.image, !path.isEmpty {
            mProfile.sd_setImage(with: URL(string: path), placeholderImage: UIImage(named: "profile-placeholder"))
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.ProgressHUDShow(text: "")
        
        getAllFundraiserMembersRecentActivities(fundraiserId: FundraiserModel.data!.uid ?? "123") { salesMemberModels, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                self.memberModels.removeAll()
                self.memberModels.append(contentsOf: salesMemberModels ?? [])
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        totalEarningCount.text = "$\(FundraiserModel.data!.totalEarning ?? 0)"
        totalSalesCount.text = "\(FundraiserModel.data!.totalSales ?? 0)"
    }
    
    @objc func cellClicked(value : MyGesture){
        performSegue(withIdentifier: "home_MemberTransactionSeg", sender: memberModels[value.index])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "home_MemberTransactionSeg" {
            if let VC = segue.destination as? SalesMemberTransactionsViewController {
                if let memberModel = sender as? SalesMemberModel {
                    VC.memberModel  = memberModel
                }
            }
        }
    }
    
}
extension SalesDashboardViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noRecentActivityAvailable.isHidden = memberModels.count > 0 ? true : false
        return memberModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell", for: indexPath) as? MembersTableViewCell {
            
            let memberModel = memberModels[indexPath.row]
        
            cell.mProfile.layer.cornerRadius = 8
            cell.mName.text = memberModel.name ?? ""
            
            cell.mSales.text = "\(memberModel.totalSales ?? 0) Sales"
            
            if let path = memberModel.profilePic, !path.isEmpty {
                cell.mProfile.sd_setImage(with: URL(string: path), placeholderImage: UIImage(named: "profile-placeholder"))
            }
            
            let myGest = MyGesture(target: self, action: #selector(cellClicked(value: )))
            myGest.index = indexPath.row
            cell.mView.isUserInteractionEnabled = true
            cell.mView.addGestureRecognizer(myGest)
            
            return cell
        }
        return MembersTableViewCell()
    }
    
    
    
    
}
