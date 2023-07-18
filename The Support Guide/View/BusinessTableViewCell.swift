//
//  BusinessTableViewCell.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 28/04/23.
//

import UIKit

class BusinessTableViewCell : UITableViewCell {

    
    @IBOutlet weak var mView: UIView!
    
    @IBOutlet weak var mProfile: UIImageView!
    @IBOutlet weak var mName: UILabel!
    @IBOutlet weak var mAddress: UILabel!
    @IBOutlet weak var mOffersCount: UILabel!
    @IBOutlet weak var miles: UILabel!
    
    
    override class func awakeFromNib() {
        
    }
    
}
