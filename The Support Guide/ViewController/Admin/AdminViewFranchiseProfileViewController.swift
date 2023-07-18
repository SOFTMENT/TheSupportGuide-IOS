//
//  AdminViewFundraiserProfileViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 18/05/23.
//

import UIKit

class AdminViewFranchiseProfileViewController : UIViewController {
    
    @IBOutlet weak var fundraiserSalesView: UIView!
    @IBOutlet weak var businessSalesView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var franchiseName: UILabel!
    @IBOutlet weak var franchiseName2: UILabel!
    
    @IBOutlet weak var editBtn: UIButton!
    
    @IBOutlet weak var franchiseDetails: UILabel!
    
    @IBOutlet weak var franchiseImage: UIImageView!
    
   
    @IBOutlet weak var businessesCountView: UIView!
    @IBOutlet weak var businessesCount: UILabel!
    
    @IBOutlet weak var fundraiserCountView: UIView!
    @IBOutlet weak var fundraiserCount: UILabel!
    
    @IBOutlet weak var salesView: UIView!
    
    @IBOutlet weak var businessSales: UILabel!
    @IBOutlet weak var fundraiserSales: UILabel!
    
    
    @IBOutlet weak var pipelinesView: UIView!
    
    @IBOutlet weak var goalsView: UIView!
    var franchiseModel : FranchiseModel?
    override func viewDidLoad() {
        
        guard let franchiseModel = franchiseModel else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        getB2BAccountsCount(by: franchiseModel.uid ?? "123") { count in
            self.businessesCount.text = "\(count)"
        }
        
        getFundraiserAccountsCount(by: franchiseModel.uid ?? "123") { count in
            self.fundraiserCount.text = "\(count)"
        }
        
        
        businessSales.text = "\(franchiseModel.totalBusinessEarning ?? 0)"
        fundraiserSales.text  = "\(franchiseModel.totalFundraiserEarning ?? 0)"
        
        editBtn.layer.cornerRadius = 4
        editBtn.dropShadow()
        
        franchiseName.text = franchiseModel.name ?? "ERROR"
        franchiseName2.text = franchiseModel.name ?? "ERROR"
        franchiseDetails.text = franchiseModel.about ?? "ERROR"
        
        franchiseImage.makeRounded()
        if let sImage = franchiseModel.image , !sImage.isEmpty {
            franchiseImage.sd_setImage(with: URL(string: sImage), placeholderImage: UIImage(named: "profile-placeholder"))
        }
        
        businessesCountView.layer.cornerRadius = 8
        fundraiserCountView.layer.cornerRadius = 8
        
        salesView.layer.cornerRadius = 8
    
        pipelinesView.layer.cornerRadius = 8
        pipelinesView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pipelineClicked)))
        
        goalsView.layer.cornerRadius = 8
        goalsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goalsClicked)))
    
        backView.isUserInteractionEnabled = true
        backView.dropShadow()
        backView.layer.cornerRadius = 8
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        businessSalesView.isUserInteractionEnabled = true
        businessSalesView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(businessSalesViewClicked)))
        
        fundraiserSalesView.isUserInteractionEnabled = true
        fundraiserSalesView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(fundraiserSalesViewClicked)))
    }
    
    @objc func businessSalesViewClicked(){
        performSegue(withIdentifier: "businessTransactionSeg", sender: nil)
    }
    
    @objc func fundraiserSalesViewClicked(){
        performSegue(withIdentifier: "fundrasierTransactionSeg", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editFranchiseSeg" {
            if let VC = segue.destination as? EditFranchiseViewController {
                VC.franchiseModel = franchiseModel
            }
        }
        else if segue.identifier == "adminGoalsSeg" {
            if let VC = segue.destination as? AdminGoalsViewController {
                VC.franchiseId = self.franchiseModel!.uid ?? "123"
            }
        }
        else if segue.identifier == "businessTransactionSeg" {
            if let VC = segue.destination as? AdminBusinessSalesViewController {
                VC.franchiseId = self.franchiseModel!.uid
            }
        }
        else if segue.identifier == "fundrasierTransactionSeg" {
            if let VC = segue.destination as? AdminFundrasierSalesViewController {
                VC.franchiseId = self.franchiseModel!.uid
            }
        }
        else if segue.identifier == "adminPipelineSeg" {
            if let VC = segue.destination as? AdminPipelineViewController {
                VC.franchiseId = self.franchiseModel!.uid 
            }
        }
        else if segue.identifier == "franchiseGoalSeg" {
            if let VC = segue.destination as? FranchiseGoalsViewController {
                VC.franchiseId = self.franchiseModel!.uid
            }
        }
    }
    @IBAction func editBtnClicked(_ sender: Any) {
        performSegue(withIdentifier: "editFranchiseSeg", sender: nil)
    }
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
    @objc func pipelineClicked(){
        performSegue(withIdentifier: "adminPipelineSeg", sender: nil)
    }
    
    
    @objc func goalsClicked(){
        performSegue(withIdentifier: "franchiseGoalSeg", sender: nil)
    }
    
    
    
}
