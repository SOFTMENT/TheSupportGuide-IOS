//
//  RedeemHistoryModel.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 12/06/23.
//

import UIKit

class RedeemHistoryModel : NSObject, Codable {

    var id : String?
    var date : Date?
    var userId : String?
    var voucherId : String?
    var voucherTitle : String?
    var voucherConditions : String?
    var voucherImage : String?
    var b2bId : String?
    var isFree : Bool?
}
