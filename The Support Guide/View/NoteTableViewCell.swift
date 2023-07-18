//
//  NoteTableViewCell.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 25/05/23.
//

import UIKit

class NoteTableViewCell : UITableViewCell {
    
    
    @IBOutlet weak var mNote: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var mView: UIView!
    
    override class func awakeFromNib() {
        
    }
    
}
