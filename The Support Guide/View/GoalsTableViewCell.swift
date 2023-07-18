//
//  GoalsTableViewCell.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 19/05/23.
//

import UIKit

class GoalsTableViewCell : UITableViewCell {
    
 
    @IBOutlet weak var finalDate: UILabel!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var note: UILabel!
    @IBOutlet weak var goalProgress: UIProgressView!
    @IBOutlet weak var goalCount: UILabel!
    @IBOutlet weak var mView: UIView!
    
    override class func awakeFromNib() {
        
    }
    
}
