//
//  PipelineTableViewCell.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 22/05/23.
//

import UIKit

class PipelineTableViewCell : UITableViewCell {
 
    @IBOutlet weak var mImage: UIImageView!
    @IBOutlet weak var mName: UILabel!
    @IBOutlet weak var mPhone: UILabel!
    @IBOutlet weak var mMail: UILabel!
    @IBOutlet weak var mLevelView: UIView!
    @IBOutlet weak var mLevel: UILabel!
    @IBOutlet weak var reminderBtn: UIButton!
    @IBOutlet weak var mView: UIView!
    
    
    override class func awakeFromNib() {
        
    }
    
    
}
