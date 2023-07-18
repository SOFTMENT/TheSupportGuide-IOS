//
//  NotificationViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 09/05/23.
//

import UIKit


class NotificationViewController : UIViewController {

    @IBOutlet weak var no_notificatons_available: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backView: UIView!
    
    var notifications : [NotificationModel] = []
    override func viewDidLoad() {
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.delegate = self
        tableView.dataSource = self
        
        backView.isUserInteractionEnabled = true
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        getAllNotifications()
    }
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    public func getAllNotifications(){
        ProgressHUDShow(text: "")
        FirebaseStoreManager.db.collection("Notifications").order(by: "notificationTime",descending: true).getDocuments { snapshot, error in
            self.ProgressHUDHide()
            if error == nil {
                self.notifications.removeAll()
                if let snap = snapshot, !snap.isEmpty {
                    for qdr in  snap.documents{
                        if let notification = try? qdr.data(as: NotificationModel.self) {
                            self.notifications.append(notification)
                        }
                    }
                   
                }
                self.tableView.reloadData()
            }
            else {
                self.showError(error!.localizedDescription)
            }
        }
    }
}


extension NotificationViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if notifications.count > 0 {
            no_notificatons_available.isHidden = true
        }
        else {
            no_notificatons_available.isHidden = false
        }
    
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "notificationscell", for: indexPath) as? NotificationTableViewCell {
            
            cell.mView.dropShadow()
            cell.mView.layer.cornerRadius = 12
            
            let notification = notifications[indexPath.row]
            cell.mTitle.text = notification.title ?? "Something Went Wrong"
            cell.mMessage.text = notification.message ?? "Something Went Wrong"
            cell.mHour.text = (notification.notificationTime ?? Date()).timeAgoSinceDate()
            
            return cell
        }
        return NotificationTableViewCell()
    }
    
    
}
