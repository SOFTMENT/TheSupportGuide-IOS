//
//  FranchiseAddNoteViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 25/05/23.
//

import UIKit

class FranchiseAddNoteViewController : UIViewController {
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var noteTV: UITextView!
    
    @IBOutlet weak var addBtn: UIButton!
    var pipelineId : String?
    
    override func viewDidLoad() {
        
        if pipelineId == nil {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        backView.isUserInteractionEnabled = true
        backView.dropShadow()
        backView.layer.cornerRadius = 8
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        noteTV.layer.cornerRadius = 8
        noteTV.layer.borderWidth = 1
        noteTV.layer.borderColor = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1).cgColor
        noteTV.contentInset = UIEdgeInsets(top: 6, left: 5, bottom: 6, right: 6)
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        addBtn.layer.cornerRadius = 8
    }
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    
    @IBAction func addBtnClicked(_ sender: Any) {
        let sNote = noteTV.text
        if sNote == "" {
            self.showToast(message: "Enter Note")
        }
        else {
            ProgressHUDShow(text: "")
            let noteModel = NoteModel()
            noteModel.time = Date()
            noteModel.note = sNote
            self.addPipelineNote(franchiseId: FranchiseModel.data!.uid ?? "123", pipelineId: pipelineId!, noteModel: noteModel) { isCompleted, error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error)
                }
                else {
                    self.showToast(message: "Note Added")
                    let seconds = 2.5
                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                        self.dismiss(animated: true)
                    }
                }
            }
        }
    }
    
}
