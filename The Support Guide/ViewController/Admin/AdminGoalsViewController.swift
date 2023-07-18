//
//  AdminGoalsViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 19/05/23.
//

import UIKit

class AdminGoalsViewController : UIViewController {
    
    
    @IBOutlet weak var noGoalsAvailable: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var addView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var goalModels = Array<GoalModel>()
    var mainGoalModels = Array<GoalModel>()
    var franchiseId : String?
    var franchiseTypeSelected : FranchiseType = .B2B
    override func viewDidLoad() {
        
        
        guard let franchiseId = franchiseId else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        addView.isUserInteractionEnabled = true
        addView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addGoalClicked)))
        
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributes, for: .selected)
        
        getAllAdminGoals(by: franchiseId) { goalModels, error in
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "adminAddGoalSeg" {
            if let VC = segue.destination as? AddGoalViewController {
                VC.franchiseId = self.franchiseId
            }
        }
    }
    
    @objc func addGoalClicked(){
            performSegue(withIdentifier: "adminAddGoalSeg", sender: nil)
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
extension AdminGoalsViewController : UITableViewDelegate, UITableViewDataSource {
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
            cell.goalProgress.progress = Float(0 / (goalModel.target ?? 1))
            cell.goalCount.text = "0/\(goalModel.target ?? 1)"
            
            return cell
        }
        return GoalsTableViewCell()
    }
    
    
    
    
}
