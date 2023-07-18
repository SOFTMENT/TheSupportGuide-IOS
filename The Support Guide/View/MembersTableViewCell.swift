//
//  MembersTableViewCell.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 06/06/23.
//

import UIKit

class MembersTableViewCell : UITableViewCell {
    
    @IBOutlet weak var mProfile: UIImageView!
    @IBOutlet weak var mName: UILabel!
    @IBOutlet weak var mSales: UILabel!
    @IBOutlet weak var mView: UIView!
    
    
    override class func awakeFromNib() {
        
    }
    
}
