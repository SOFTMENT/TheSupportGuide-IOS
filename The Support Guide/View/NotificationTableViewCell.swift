//
//  NotificationTableViewCell.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 09/05/23.
//


import UIKit

class NotificationTableViewCell : UITableViewCell {
    
    @IBOutlet weak var mHour: UILabel!
    @IBOutlet weak var mTitle: UILabel!
    @IBOutlet weak var mMessage: UILabel!
    @IBOutlet weak var mView: UIView!
    
    override func awakeFromNib() {
        
    }
}
