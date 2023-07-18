//
//  FranchiseAddGoalsViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 22/05/23.
//


import UIKit

class FranchiseAddGoalsViewController : UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var enterTarget: UITextField!
    @IBOutlet weak var selectDate: UITextField!
    @IBOutlet weak var setBtn: UIButton!
    let datePicker = UIDatePicker()

    @IBOutlet weak var businessView: UIStackView!
    @IBOutlet weak var fundraiserView: UIStackView!
    @IBOutlet weak var fundraiserCheck: UIButton!
    @IBOutlet weak var businessCheck: UIButton!
    @IBOutlet weak var note: UITextView!
    var franchiseType : FranchiseType?
    
    override func viewDidLoad() {
     
        
        
        businessView.isUserInteractionEnabled = true
        businessView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(businessClicked)))
        
        fundraiserView.isUserInteractionEnabled = true
        fundraiserView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(fundraiserClicked)))
        
        note.layer.cornerRadius = 8
        note.layer.borderWidth = 1
        note.layer.borderColor = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1).cgColor
        note.contentInset = UIEdgeInsets(top: 6, left: 5, bottom: 6, right: 6)
        
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        backView.isUserInteractionEnabled = true
        
        setBtn.layer.cornerRadius = 8
        
        enterTarget.delegate = self
        selectDate.delegate = self
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        createDatePicker()
    }
    
    @objc func businessClicked(){
        franchiseType = .B2B
        businessCheck.isSelected = true
        fundraiserCheck.isSelected = false
    }
    
    @objc func fundraiserClicked(){
        franchiseType = .FUNDRAISER
        businessCheck.isSelected = false
        fundraiserCheck.isSelected = true
    }
    
    func createDatePicker() {
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }

        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(dateDoneBtnTapped))
        toolbar.setItems([done], animated: true)
        
        selectDate.inputAccessoryView = toolbar
        
        datePicker.datePickerMode = .date
        selectDate.inputView = datePicker
    }
    @objc func dateDoneBtnTapped() {
        view.endEditing(true)
        let selectedDate = datePicker.date
        self.selectDate.text = convertDateFormaterWithSlash(selectedDate)
    }
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    
    @IBAction func setBtnClicked(_ sender: Any) {
        let sTarget = enterTarget.text
        let sDate = selectDate.text
        let sNote = note.text
        if franchiseType == nil {
            self.showToast(message: "Select Type")
        }
        else if sTarget == "" {
            self.showToast(message: "Enter Target")
        }
        else if sDate == "" {
            self.showToast(message: "Select Date")
        }
        else if sNote == "" {
            self.showToast(message: "Enter Note")
        }
        else {
            ProgressHUDShow(text: "")
            let goalModel = GoalModel()
            goalModel.target = Int(sTarget!)
            goalModel.franchiseId = FranchiseModel.data!.uid 
            goalModel.finalDate = self.datePicker.date
            goalModel.goalCreate = Date()
            goalModel.note = sNote
            if franchiseType == .B2B {
                goalModel.type = "B2B"
            }
            else {
                goalModel.type = "FUNDRAISER"
            }
            self.addFranchiseGoal(goalModel: goalModel, completion: { isSuccess, error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error)
                }
                else {
                    if isSuccess {
                        self.showToast(message: "Goal Set")
                        let seconds = 2.5
                        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                            self.dismiss(animated: true)
                        }
                    }
                }
            })
            
        }
    }
}

extension FranchiseAddGoalsViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == selectDate
        {
            return false
        }
        
        
        return true
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}

