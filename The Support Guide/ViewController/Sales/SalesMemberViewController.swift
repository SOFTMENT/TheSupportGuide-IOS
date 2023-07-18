//
//  SalesMemberViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 31/05/23.
//

import UIKit

class SalesMemberViewController : UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addView: UIImageView!
    @IBOutlet weak var noMembersAvailable: UILabel!
    var memberModels = Array<SalesMemberModel>()
    override func viewDidLoad() {
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        addView.isUserInteractionEnabled = true
        addView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addViewClicked)))
        
        getAllFundraiserMembers(fundraiserId: FundraiserModel.data!.uid ?? "123") { salesMemberModels, error in
            self.memberModels.removeAll()
            self.memberModels.append(contentsOf: salesMemberModels ?? [])
            self.tableView.reloadData()
        }
    }
    
    @objc func addViewClicked(){
        performSegue(withIdentifier: "addMemberSeg", sender: nil)
    }
    
    @objc func cellClicked(value : MyGesture){
        performSegue(withIdentifier: "member_MemberTransactionSeg", sender: memberModels[value.index])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "member_MemberTransactionSeg" {
            if let VC = segue.destination as? SalesMemberTransactionsViewController {
                if let memberModel = sender as? SalesMemberModel {
                    VC.memberModel  = memberModel
                }
            }
        }
    }
    
}

extension SalesMemberViewController : UITableViewDelegate, UITableViewDataSource {
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
