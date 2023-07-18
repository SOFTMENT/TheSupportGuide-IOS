//
//  FranchiseViewPipelineViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 25/05/23.
//

import UIKit

class FranchiseViewPipelineViewController : UIViewController {
    @IBOutlet weak var noNotesAvailable: UILabel!
    
    @IBOutlet weak var backView: UIView!
   
    @IBOutlet weak var convertBtn: UIButton!
    
    @IBOutlet weak var headTitle: UILabel!
    @IBOutlet weak var mProfile: UIImageView!
    @IBOutlet weak var editBtn: UIButton!
    
    @IBOutlet weak var mEmail: UILabel!
    @IBOutlet weak var mTitle: UILabel!
    
    @IBOutlet weak var mPhone: UILabel!
    
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var typeView: UIView!
    
    @IBOutlet weak var levelCount: UILabel!
    @IBOutlet weak var levelView: UIView!
    @IBOutlet weak var mAbout: UILabel!
    
    @IBOutlet weak var addView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    var pipelineModel : PipelineModel?
    var noteModels = Array<NoteModel>()
    override func viewDidLoad() {
        
        guard let pipelineModel = pipelineModel else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        backView.isUserInteractionEnabled = true
        backView.dropShadow()
        backView.layer.cornerRadius = 8
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        headTitle.text = pipelineModel.name ?? ""
        convertBtn.layer.cornerRadius = 8
        editBtn.layer.cornerRadius = 8
        
        mProfile.layer.cornerRadius = 8
        if let profilePath = pipelineModel.image, !profilePath.isEmpty {
            mProfile.sd_setImage(with: URL(string: profilePath), placeholderImage: UIImage(named: "profile-placeholder"))
        }
        
        mTitle.text = pipelineModel.name ?? ""
        mEmail.text = pipelineModel.email ?? ""
        mPhone.text = pipelineModel.phoneNumber ?? ""
        typeView.layer.cornerRadius = 6
        type.text = (pipelineModel.type ?? "") == "b2b" ? "B2B" : "SALES"
        
        levelView.layer.cornerRadius = 6
        levelCount.text = "\(pipelineModel.level ?? 0)"
        
        mAbout.text = pipelineModel.aboutBusiness ?? ""
        
        tableView.dataSource = self
        tableView.delegate = self
        
        addView.isUserInteractionEnabled = true
        addView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addNoteClicked)))
        
        self.ProgressHUDShow(text: "")
        getAllNotes(franchiseId: pipelineModel.franchiseId ?? "123", pipelineId: pipelineModel.id ?? "123") { noteModels, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error)
            }
            else {
                self.noteModels.removeAll()
                self.noteModels.append(contentsOf: noteModels ?? [])
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func addNoteClicked(){
        performSegue(withIdentifier: "addNoteSeg", sender: nil)
    }
    
    public func updateTableViewHeight(){
        
        self.tableViewHeight.constant = self.tableView.contentSize.height
        self.tableView.layoutIfNeeded()
    }
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
    @IBAction func convertBtnClicked(_ sender: Any) {
        if pipelineModel!.type == "b2b" {
            performSegue(withIdentifier: "pipelineAddB2bSeg", sender: nil)
        }
        else {
            performSegue(withIdentifier: "pipelineAddSalesSeg", sender: nil)
        }
        
    }
    @IBAction func editBtnClicked(_ sender: Any) {
        performSegue(withIdentifier: "editPipelineSeg", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pipelineAddB2bSeg" {
            if let VC = segue.destination as? FranchiseAddB2BViewController {
                VC.pipeLineModel = pipelineModel
            }
        }
        else if segue.identifier == "pipelineAddSalesSeg" {
            if let VC = segue.destination as? FranchiseAddFundraiserViewController {
                VC.pipeLineModel = pipelineModel
            }
        }
        else if segue.identifier == "addNoteSeg" {
            if let VC = segue.destination as? FranchiseAddNoteViewController {
                VC.pipelineId = pipelineModel!.id
            }
        }
        else if segue.identifier == "editPipelineSeg" {
            if let VC = segue.destination as? FranchiseEditPipelineController {
                VC.piplineModel = pipelineModel
            }
        }
    }
    
}

extension FranchiseViewPipelineViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noNotesAvailable.isHidden = noteModels.count > 0 ? true : false
        return noteModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath) as? NoteTableViewCell {
            
            cell.mView.layer.cornerRadius = 8
            let noteModel = noteModels[indexPath.row]
            cell.mNote.text = noteModel.note ?? ""
            cell.time.text = self.convertDateForVoucher(noteModel.time ?? Date())
            
            DispatchQueue.main.async {
                self.updateTableViewHeight()
            }
           
            
            return cell
        }
        return NoteTableViewCell()
    }
    
    
    
    
}
