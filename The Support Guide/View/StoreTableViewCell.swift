//
//  StoreTableViewCell.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 10/06/23.
//

import UIKit

class StoreTableViewCell : UITableViewCell {
    
    @IBOutlet weak var storeView: UIView!
    @IBOutlet weak var storeLocation: UILabel!
    @IBOutlet weak var storePhone: UILabel!
    @IBOutlet weak var openInMaps: UILabel!

    override class func awakeFromNib() {
        
    }
    
}
