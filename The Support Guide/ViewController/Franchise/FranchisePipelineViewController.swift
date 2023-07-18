//
//  FranchisePipelineViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 21/05/23.
//

import UIKit
import EventKit

class FranchisePipelineViewController : UIViewController {
    let eventStore = EKEventStore()
    @IBOutlet weak var noPipelineAvailable: UILabel!
    @IBOutlet weak var addView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var pipelineModels = Array<PipelineModel>()
    var mainPipelineModels = Array<PipelineModel>()
    var franchiseTypeSelected : FranchiseType = .B2B
    override func viewDidLoad() {
        
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributes, for: .selected)
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        addView.isUserInteractionEnabled = true
        addView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addViewClicked)))
        
        getAllPipelines(by: FranchiseModel.data!.uid ?? "123") { pipelineModels, error in
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
    
    @objc func addViewClicked(){
        self.performSegue(withIdentifier: "addPipelineSeg", sender: nil)
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
        performSegue(withIdentifier: "franchiseViewPipelineSeg", sender: pipelineModels[gest.index])
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "franchiseViewPipelineSeg" {
            if let VC  = segue.destination as? FranchiseViewPipelineViewController {
                if let pipelineModel = sender as? PipelineModel {
                    VC.pipelineModel = pipelineModel
                }
            }
        }
        else if segue.identifier == "followUpSeg" {
            if let VC = segue.destination as? FranchiseAddFollowUpController {
                if let name  = sender as? String {
                    VC.name = name
                }
            }
        }
    }
    
    @objc func reminderClikced(value : MyGesture){
        let pipelineModel = pipelineModels[value.index]
        performSegue(withIdentifier: "followUpSeg", sender: pipelineModel.name ?? "name")
    }
}

extension FranchisePipelineViewController : UITableViewDelegate, UITableViewDataSource {
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
