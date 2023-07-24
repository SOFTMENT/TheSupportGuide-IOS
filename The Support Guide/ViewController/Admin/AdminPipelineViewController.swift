//
//  AdminPipelineViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 11/06/23.
//


import UIKit
import EventKit

class AdminPipelineViewController : UIViewController {
    
    @IBOutlet weak var backView: UIView!
    
    let eventStore = EKEventStore()
    @IBOutlet weak var noPipelineAvailable: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var pipelineModels = Array<PipelineModel>()
    var mainPipelineModels = Array<PipelineModel>()
    var franchiseTypeSelected : FranchiseType = .B2B
    var franchiseId : String?
    override func viewDidLoad() {
        
        guard let franchiseId = franchiseId else {
            
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
            
        }
        
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributes, for: .selected)
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        backView.layer.cornerRadius = 8
      
        
        getAllPipelines(by: franchiseId) { pipelineModels, error in
            if let error = error {
                self.showError(error)
            }
            else {
                
                
                
                self.mainPipelineModels.removeAll()
             
                self.mainPipelineModels.append(contentsOf: pipelineModels ?? [])
                
                self.loadTableView(franchiseType: self.franchiseTypeSelected)
                
            }
        }
    }
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
    func AddReminder(value : PipelineModel) {

     eventStore.requestAccess(to: EKEntityType.reminder, completion: {
      granted, error in
      if (granted) && (error == nil) {
        print("granted \(granted)")


        let reminder:EKReminder = EKReminder(eventStore: self.eventStore)
          reminder.title = "Follow On - Level \(value.level ?? 1)"
        reminder.priority = 2

          reminder.notes = "\(value.name ?? "")\n\(value.phoneNumber ?? "")\n\(value.email ?? "")"


        let alarmTime = Date().addingTimeInterval(1*60*24*3)
        let alarm = EKAlarm(absoluteDate: alarmTime)
        reminder.addAlarm(alarm)
          
        reminder.calendar = self.eventStore.defaultCalendarForNewReminders()


        do {
          try self.eventStore.save(reminder, commit: true)
        } catch {
          print("Cannot save")
          return
        }
        print("Reminder saved")
      }
     })

    }
    
    func loadTableView(franchiseType : FranchiseType){
        self.franchiseTypeSelected = franchiseType
        self.pipelineModels.removeAll()
        if franchiseType == .B2B {
            self.pipelineModels.append(contentsOf: mainPipelineModels.filter { pipelineModel in
                if pipelineModel.type == "b2b" {
                    return true
                }
                return false
            })
        }
        else {
            self.pipelineModels.append(contentsOf: mainPipelineModels.filter { pipelineModel in
                if pipelineModel.type == "sales" {
                    return true
                }
                return false
            })
        }
        self.tableView.reloadData()
    }
    
 
    
    @IBAction func segmentClicked(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.loadTableView(franchiseType: .B2B)
            
        }
        else{
            self.loadTableView(franchiseType: .FUNDRAISER)
        }
    }
    
    @objc func cellClicked(gest : MyGesture){
        performSegue(withIdentifier: "adminpipelineDetailsSeg", sender: pipelineModels[gest.index])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "adminpipelineDetailsSeg" {
            if let VC  = segue.destination as? FranchiseViewPipelineViewController {
                if let pipelineModel = sender as? PipelineModel {
                    VC.pipelineModel = pipelineModel
                    VC.isAdmin = true
                }
            }
        }
    }
    
    @objc func reminderClikced(value : MyGesture){
        AddReminder(value: pipelineModels[value.index])
    }
}

extension AdminPipelineViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noPipelineAvailable.isHidden = pipelineModels.count > 0 ? true : false
        return pipelineModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "pipelineCell", for: indexPath) as? PipelineTableViewCell {
            
            cell.mView.layer.cornerRadius = 8
            cell.mLevelView.layer.cornerRadius = cell.mLevelView.bounds.height / 2
         
            cell.reminderBtn.layer.cornerRadius = 6
            let pipelineModel = pipelineModels[indexPath.row]
        
            cell.mImage.layer.cornerRadius = 8
            
            if let imagePath = pipelineModel.image, !imagePath.isEmpty {
                cell.mImage.sd_setImage(with: URL(string: imagePath), placeholderImage: UIImage(named: "placeholder"))
            }
            cell.mLevel.text = "\(pipelineModel.level ?? 1)"
            cell.mName.text = pipelineModel.name ?? ""
            cell.mMail.text = pipelineModel.email ?? ""
            cell.mPhone.text = pipelineModel.phoneNumber ?? ""
        
            cell.mView.isUserInteractionEnabled = true
            let gest = MyGesture(target: self, action: #selector(cellClicked(gest: )))
            gest.index = indexPath.row
            cell.mView.addGestureRecognizer(gest)
            
            cell.reminderBtn.isUserInteractionEnabled = true
            let reminderGest = MyGesture(target: self, action: #selector(reminderClikced(value:)))
            reminderGest.index = indexPath.row
            cell.reminderBtn.addGestureRecognizer(reminderGest)
            
            return cell
        }
        return PipelineTableViewCell()
    }

}
