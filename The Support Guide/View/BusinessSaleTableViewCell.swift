//
//  BusinessSaleTableViewCell.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 11/06/23.
//

import UIKit

class BusinessSaleTableViewCell : UITableViewCell {
    
    
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var mProfile: UIImageView!
    @IBOutlet weak var mName: UILabel!
    @IBOutlet weak var mAddress: UILabel!
    @IBOutlet weak var mDate: UILabel!

    @IBOutlet weak var mAmount: UILabel!
    @IBOutlet weak var mAmountView: UIView!
    
    @IBOutlet weak var mJoin: UILabel!
    @IBOutlet weak var mJoinView: UIView!
    
    override class func awakeFromNib() {
        
    }
    
}
