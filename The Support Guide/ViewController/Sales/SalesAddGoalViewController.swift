//
//  SalesAddGoalViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 26/06/23.
//


import UIKit

class SalesAddGoalViewController : UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var enterTarget: UITextField!
    @IBOutlet weak var selectDate: UITextField!
    @IBOutlet weak var setBtn: UIButton!
    let datePicker = UIDatePicker()
    let personPicker = UIPickerView()
    @IBOutlet weak var memberTF: UITextField!
    var memberModels = Array<SalesMemberModel>()
    override func viewDidLoad() {
     
        
        memberTF.delegate = self
        personPicker.delegate = self
        personPicker.dataSource = self
        memberTF.setRightIcons(icon: UIImage(named: "down-arrow")!)
        memberTF.rightView?.isUserInteractionEnabled = true
        
        
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
        
        
        ProgressHUDShow(text: "")
        self.getAllFundraiserMembers(fundraiserId: FundraiserModel.data!.uid ?? "123") { memberModels, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                self.memberModels.removeAll()
                self.memberModels.append(contentsOf: memberModels ?? [])
                self.personPicker.reloadAllComponents()
            }
        }
        
        // ToolBar
        let selectPersonBar = UIToolbar()
        selectPersonBar.barStyle = .default
        selectPersonBar.isTranslucent = true
        selectPersonBar.tintColor = .link
        selectPersonBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton1 = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(personPickerDoneClicked))
        let spaceButton1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton1 = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(personPickerCancelClicked))
        selectPersonBar.setItems([cancelButton1, spaceButton1, doneButton1], animated: false)
        selectPersonBar.isUserInteractionEnabled = true
        memberTF.inputAccessoryView = selectPersonBar
        memberTF.inputView = personPicker
    }
    @objc func personPickerDoneClicked(){
        
        
        
        
        memberTF.resignFirstResponder()
        let row = personPicker.selectedRow(inComponent: 0)
        
        if memberModels.count > 0 {
            memberTF.text = memberModels[row].name ?? ""
        }
      
        
       
    }
    
    @objc func personPickerCancelClicked(){
        memberTF.resignFirstResponder()
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
        let sPerson = memberTF.text
        
        if sPerson == "" {
            self.showToast(message: "Select Member")
        }
        else if sTarget == "" {
            self.showToast(message: "Enter Target")
        }
        else if sDate == "" {
            self.showToast(message: "Select Date")
        }
    
        else {
            
            let row = personPicker.selectedRow(inComponent: 0)
            
            
            ProgressHUDShow(text: "")
            let goalModel = GoalModel()
            goalModel.target = Int(sTarget!)
            goalModel.franchiseId = FundraiserModel.data!.franchiseId
            goalModel.finalDate = self.datePicker.date
            goalModel.goalCreate = Date()
            goalModel.memberName = self.memberModels[row].name ?? "123"
            goalModel.memberId = self.memberModels[row].id ?? "123"
            
            self.addFundraiserGoal(fundraiserId : FundraiserModel.data!.uid ?? "123",goalModel: goalModel, completion: { isSuccess, error in
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

extension SalesAddGoalViewController : UITextFieldDelegate {
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

extension SalesAddGoalViewController : UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
     
            return self.memberModels.count
       
         
        

    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

            return self.memberModels[row].name ?? ""
    
        
    }

}
