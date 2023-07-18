//
//  BusinessTransactionModel.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 11/06/23.
//

import UIKit

class BusinessTransactionModel : NSObject, Codable {
    
    var id : String?
    var businessId : String?
    var franchiseId : String?
    var date : Date?
    var amount : Int?
    var type : String?
    
}
