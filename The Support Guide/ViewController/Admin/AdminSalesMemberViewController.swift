//
//  AdminSalesMemberViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 11/06/23.
//

import UIKit

class AdminSalesMemberViewController : UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noMembersAvailable: UILabel!
    var memberModels = Array<SalesMemberModel>()
    var fundrasierId : String?
    override func viewDidLoad() {
        
        guard let fundrasierId = fundrasierId else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        tableView.delegate = self
        tableView.dataSource = self
      
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        backView.layer.cornerRadius = 8
        
        getAllFundraiserMembers(fundraiserId: fundrasierId) { salesMemberModels, error in
            self.memberModels.removeAll()
            self.memberModels.append(contentsOf: salesMemberModels ?? [])
            self.tableView.reloadData()
        }
    }
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
    @objc func cellClicked(value : MyGesture){
        performSegue(withIdentifier: "adminMemberTransSeg", sender: memberModels[value.index])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "adminMemberTransSeg" {
            if let VC = segue.destination as? SalesMemberTransactionsViewController {
                if let memberModel = sender as? SalesMemberModel {
                    VC.memberModel  = memberModel
                    VC.fromAdminPanel = true
                }
            }
        }
    }
    
}

extension AdminSalesMemberViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noMembersAvailable.isHidden = memberModels.count > 0 ? true : false
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
