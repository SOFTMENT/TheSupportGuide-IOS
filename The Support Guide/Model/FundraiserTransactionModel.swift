//
//  FundraiserTransactionModel.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 09/06/23.
//

import UIKit

class FundraiserTransactionModel : NSObject, Codable {
    
    var id : String?
    var date : Date?
    var userId : String?
    var memberId : String?
    var userName : String?
    var userImage : String?
    var amount : Int?
    var fundraiserId : String?
   
    
}
