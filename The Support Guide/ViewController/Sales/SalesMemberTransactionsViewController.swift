//
//  SalesMemberTransactionsViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 09/06/23.
//

import UIKit

class SalesMemberTransactionsViewController : UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var mProfile: UIImageView!
    @IBOutlet weak var mName: UILabel!
    @IBOutlet weak var mSales: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noSalesAvailable: UILabel!
    var memberModel : SalesMemberModel?
    var transactionModels = Array<FundraiserTransactionModel>()
    var fromAdminPanel : Bool?
    override func viewDidLoad() {
        
        guard let memberModel = memberModel else {
            
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        if let fromAdminPanel = fromAdminPanel, fromAdminPanel {
            DispatchQueue.main.async {
                self.editBtn.isHidden = true
            }
        }
        
        editBtn.layer.cornerRadius = 8
        
        mProfile.layer.cornerRadius = 8
       
        
        tableView.delegate = self
        tableView.dataSource = self
        
        ProgressHUDShow(text: "")
        getAllFundraiserTransactionsBy(memberId: memberModel.id ?? "123", franchiseId: nil) {transactionModels, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                self.transactionModels.removeAll()
                self.transactionModels.append(contentsOf: transactionModels ?? [])
                self.tableView.reloadData()
            }
        }
        
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
    }
    override func viewWillAppear(_ animated: Bool) {
        if let path = memberModel!.profilePic,!path.isEmpty {
            mProfile.sd_setImage(with: URL(string: path), placeholderImage: UIImage(named: "profile-placeholder"))
        }
        mName.text = memberModel!.name ?? ""
        mSales.text = "\(memberModel!.totalSales ?? 0) Sales"
    }
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
    @IBAction func editBtnClicked(_ sender: Any) {
        performSegue(withIdentifier: "editMemberSeg", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editMemberSeg" {
            if let VC = segue.destination as? SalesEditMemberViewController {
                VC.memberModel = memberModel
            }
        }
    }
}

extension SalesMemberTransactionsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noSalesAvailable.isHidden = transactionModels.count > 0 ? true : false
        return transactionModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "memberTransactionCell", for: indexPath) as? MemberTransactionTableCell {
            
            let transactionModel = transactionModels[indexPath.row]
            cell.mProfile.layer.cornerRadius = 8
            if let path = transactionModel.userImage, !path.isEmpty {
                cell.mProfile.sd_setImage(with: URL(string: path), placeholderImage: UIImage(named: "profile-placeholder"))
            }
            cell.mName.text = transactionModel.userName ?? ""
            cell.mAmount.text  = "$\(transactionModel.amount ?? 0)"
            cell.mDate.text = convertDateAndTimeFormater(transactionModel.date ?? Date())
            
            return cell
        }
        return MemberTransactionTableCell()
        
    }
    
    
    
    
}
