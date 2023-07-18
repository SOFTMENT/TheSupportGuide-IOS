//
//  SalesMemberModel.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 08/06/23.
//

import UIKit

class SalesMemberModel : NSObject, Codable {
    
    var id : String?
    var name : String?
    var profilePic : String?
    var fundraiserId : String?
    var createDate : Date?
    var totalSales : Int?
    var totalSaleUpdate : Date?
}
