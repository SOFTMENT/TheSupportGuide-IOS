//
//  FranchiseGoalsViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 22/05/23.
//


import UIKit

class FranchiseGoalsViewController : UIViewController {
   
    @IBOutlet weak var noGoalsAvailable: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var addView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var goalModels = Array<GoalModel>()
    var mainGoalModels = Array<GoalModel>()
    var franchiseTypeSelected : FranchiseType = .B2B
    var franchiseId : String?
    var isAdmin = false
    var id = ""
    override func viewDidLoad() {
        
        
        if let franchiseId = franchiseId {
            id = franchiseId
            isAdmin = true
        }
        else {
            id = FranchiseModel.data!.uid ?? "123"
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        addView.isUserInteractionEnabled = true
        addView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addGoalClicked)))
        
        if isAdmin {
            addView.isHidden = true
        }
        
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributes, for: .selected)
        
        getAllFranchiseGoals(by: id) { goalModels, error in
            if let error = error {
                self.showError(error)
            }
            else {
                self.mainGoalModels.removeAll()
             
                self.mainGoalModels.append(contentsOf: goalModels ?? [])
                
                self.loadTableView(franchiseType: self.franchiseTypeSelected)
                
            }
        }
    }
    
    @objc func deleteGoalClicked(value : MyGesture){
        
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this goal?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            self.ProgressHUDShow(text: "")
            FirebaseStoreManager.db.collection("Franchises").document(self.id).collection("Goals").document(value.id).delete { error in
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
    
    func loadTableView(franchiseType : FranchiseType){
        self.franchiseTypeSelected = franchiseType
        self.goalModels.removeAll()
        if franchiseType == .B2B {
            self.goalModels.append(contentsOf: mainGoalModels.filter { goalModel in
                if goalModel.type == "B2B" {
                    return true
                }
                return false
            })
        }
        else {
            self.goalModels.append(contentsOf: mainGoalModels.filter { goalModel in
                if goalModel.type == "FUNDRAISER" {
                    return true
                }
                return false
            })
        }
        self.tableView.reloadData()
    }
    
  
    
    @objc func addGoalClicked(){
            performSegue(withIdentifier: "franchiseAddGoalSeg", sender: nil)
    }
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
  
    @IBAction func segmentClicked(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.loadTableView(franchiseType: .B2B)
            
        }
        else{
            self.loadTableView(franchiseType: .FUNDRAISER)
        }
    }
    
}
extension FranchiseGoalsViewController : UITableViewDelegate, UITableViewDataSource {
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
            cell.note.text = goalModel.note ?? "ERROR"
            
            if isAdmin {
                cell.deleteGoal.isHidden = true
            }
            else {
                cell.deleteGoal.isHidden = false
                cell.deleteGoal.isUserInteractionEnabled = true
                let deleteGest = MyGesture(target: self, action: #selector(deleteGoalClicked(value: )))
                deleteGest.id = goalModel.id ?? ""
                cell.deleteGoal.addGestureRecognizer(deleteGest)
            }
            
            if goalModel.type == "B2B" {
                self.getAllBusinessesByDate(by: goalModel.franchiseId ?? "123", startDate: goalModel.goalCreate ?? Date(), endDate: goalModel.finalDate ?? Date()) { b2bModels, error in
                    var count  = 0
                    if b2bModels != nil {
                        count = b2bModels!.count
                    }
                    
                    cell.goalProgress.progress = Float(Float(count) / Float(goalModel.target ?? 1))
                    cell.goalCount.text = "\(count)/\(goalModel.target ?? 1)"
                    
                    if (goalModel.finalDate ?? Date()) < Date() && count < (goalModel.target ?? 0){
                        cell.status.text = "Due"
                        cell.status.textColor = .red
                    }
                    else if  (count >= (goalModel.target ?? 0)){
                        cell.status.text = "Achieved"
                        cell.status.textColor = .green
                    }
                    else {
                        cell.status.text = "Progress"
                        cell.status.textColor = .tintColor
                    }


                }
            }
            else {
                self.getAllFundraiserByDate(by: goalModel.franchiseId ?? "123", startDate: goalModel.goalCreate ?? Date(), endDate: goalModel.finalDate ?? Date()) { b2bModels, error in
                    var count  = 0
                    if b2bModels != nil {
                        count = b2bModels!.count
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
                        cell.status.textColor = .tintColor
                    }

                }
            }
            
            
            
            return cell
        }
        return GoalsTableViewCell()
    }
    
    
    
    
}
