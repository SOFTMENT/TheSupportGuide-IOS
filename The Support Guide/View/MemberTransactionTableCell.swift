//
//  MemberTransactionTableCell.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 09/06/23.
//

import UIKit

class MemberTransactionTableCell : UITableViewCell {
    
    @IBOutlet weak var mProfile: UIImageView!
    @IBOutlet weak var mName: UILabel!
    @IBOutlet weak var mDate: UILabel!
    @IBOutlet weak var mAmount: UILabel!
    @IBOutlet weak var mView: UIView!
    
    
    override class func awakeFromNib() {
        
    }
    
}
