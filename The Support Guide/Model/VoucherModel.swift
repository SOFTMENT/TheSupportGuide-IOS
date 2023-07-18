//
//  VoucherModel.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 30/05/23.
//

import UIKit

class VoucherModel : NSObject, Codable {
    
    var id : String?
    var title : String?
    var conditions : String?
    var isFree : Bool?
    var discounts : Int?
    var valid : Date?
    var added : Date?
    var businessUid : String?
    var mImage : String?
    var timesRedeemable : Int?
}
