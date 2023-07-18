//
//  B2bFundraiserTableViewCell.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 20/05/23.
//

import UIKit

class B2bFundraiserTableViewCell : UITableViewCell {
    
    @IBOutlet weak var mView: UIView!
   
    @IBOutlet weak var type: UILabel!
    
    @IBOutlet weak var mImage: UIImageView!
    @IBOutlet weak var typeView: UIView!
    
    @IBOutlet weak var mName: UILabel!
    
    @IBOutlet weak var mAddress: UILabel!
    
    @IBOutlet weak var phoneNumber: UILabel!
    
    @IBOutlet weak var openingTime: UILabel!
    
    @IBOutlet weak var closingTime: UILabel!
    
    @IBOutlet weak var daysLeft: UILabel!
    
    
    
    
    override class func awakeFromNib() {
        
    }
    
}
