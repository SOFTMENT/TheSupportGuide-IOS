//
//  FranchiseAddFollowUpController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 25/06/23.
//

import UIKit
import EventKit

class FranchiseAddFollowUpController : UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var selectDate: UITextField!
    @IBOutlet weak var addBtn: UIButton!
    let datePicker = UIDatePicker()
    var name : String?
    override func viewDidLoad() {
        
        if name == nil {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
        
        addBtn.layer.cornerRadius = 8
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
     
        createDateAndTimePicker()
        
    }
    func createDateAndTimePicker() {
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(dateDoneBtnTapped))
        toolbar.setItems([done], animated: true)
        
        selectDate.inputAccessoryView = toolbar
        
        datePicker.datePickerMode = .dateAndTime
        selectDate.inputView = datePicker
    }
    @objc func dateDoneBtnTapped() {
        view.endEditing(true)
        let selectedDate = datePicker.date
        selectDate.text = convertDateAndTimeFormater(selectedDate)
    }
    
    
    @objc func backBtnClicked() {
        self.dismiss(animated: true)
    }
    
    @IBAction func addBtnClicked(_ sender: Any) {
        let sDate = selectDate.text
        if sDate == "" {
            self.showToast(message: "Select time")
        }
        else {
            let eventStore : EKEventStore = EKEventStore()
                  
            // 'EKEntityTypeReminder' or 'EKEntityTypeEvent'

            eventStore.requestAccess(to: .event) { (granted, error) in
              
              if (granted) && (error == nil) {
               
                  DispatchQueue.main.async {
                      let event:EKEvent = EKEvent(eventStore: eventStore)
                      
                      event.title = self.name!
                      event.startDate = self.datePicker.date
                      event.endDate = self.datePicker.date
                
                      event.notes = "Follow Up"
                      event.calendar = eventStore.defaultCalendarForNewEvents
                      do {
                          try eventStore.save(event, span: .thisEvent)
                      } catch let error as NSError {
                          print("failed to save event with error : \(error)")
                      }
                      self.showToast(message: "Added in calendar")
                      self.selectDate.text = ""
                  }
            
              }
              
            }
        }
    }
    
}
