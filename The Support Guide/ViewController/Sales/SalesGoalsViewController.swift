//
//  SalesGoalsViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 31/05/23.
//

import UIKit

class SalesGoalsViewController : UIViewController {
   
    @IBOutlet weak var noGoalsAvailable: UILabel!
    
    @IBOutlet weak var addView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var goalModels = Array<GoalModel>()
 
    override func viewDidLoad() {
        
 
        
        tableView.delegate = self
        tableView.dataSource = self
       
        
        addView.isUserInteractionEnabled = true
        addView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addGoalClicked)))
      
        
        getAllFundraiserGoals(by: FundraiserModel.data!.uid ?? "123") { goalModels, error in
            if let error = error {
                self.showError(error)
            }
            else {
                self.goalModels.removeAll()
             
                self.goalModels.append(contentsOf: goalModels ?? [])
                
                self.tableView.reloadData()
                
            }
        }
    }

    @objc func addGoalClicked(){
            performSegue(withIdentifier: "addFundraiserGoalSeg", sender: nil)
    }
    @objc func deleteGoalClicked(value : MyGesture){
        
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this goal?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            self.ProgressHUDShow(text: "")
            FirebaseStoreManager.db.collection("Fundraisers").document(FundraiserModel.data!.uid ?? "123").collection("Goals").document(value.id).delete { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                }
                else {
                    self.showToast(message: "Deleted")
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
      
    }
}
extension SalesGoalsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noGoalsAvailable.isHidden = goalModels.count > 0 ? true : false
        return goalModels.count
    }
    
   
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "adminGoalCell", for: indexPath) as? GoalsTableViewCell {
            
            cell.mView.layer.cornerRadius = 8
            let goalModel = goalModels[indexPath.row]
            cell.startDate.text = "\(self.convertDateFormaterWithoutDash(goalModel.goalCreate ?? Date()))"
            cell.finalDate.text = "\(self.convertDateFormaterWithoutDash(goalModel.finalDate ?? Date()))"
            cell.note.text = goalModel.memberName ?? "123"
            
          
                cell.deleteGoal.isHidden = false
                cell.deleteGoal.isUserInteractionEnabled = true
                let deleteGest = MyGesture(target: self, action: #selector(deleteGoalClicked(value: )))
                deleteGest.id = goalModel.id ?? ""
                cell.deleteGoal.addGestureRecognizer(deleteGest)
            
            
            self.getAllSalesTransactionByDate(by: goalModel.memberId ?? "123", startDate: goalModel.goalCreate ?? Date(), endDate: goalModel.finalDate ?? Date()) { transactionModels, error in
                var count = 0
                
                if let transactionModels = transactionModels {
                    for transactionModel in transactionModels {
                        count = count + (transactionModel.amount ?? 0)
                    }
                }
                
                cell.goalProgress.progress = Float(Float(count) / Float(goalModel.target ?? 1))
                cell.goalCount.text = "\(count)/\(goalModel.target ?? 1)"
                
                if (goalModel.finalDate ?? Date()) < Date() && count < (goalModel.target ?? 0){
                    cell.status.text = "Due"
                    cell.status.textColor = .red
                }
                else if (count >= (goalModel.target ?? 0)){
                    cell.status.text = "Achieved"
                    cell.status.textColor = .green
                }
                else {
                    cell.status.text = "Progress"
                    cell.status.textColor = .systemBlue
                }
            }
            
            
            
            return cell
        }
        return GoalsTableViewCell()
    }
    
    
    
    
}
