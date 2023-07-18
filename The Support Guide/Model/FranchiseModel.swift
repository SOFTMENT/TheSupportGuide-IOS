//
//  FranchiseModel.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 12/05/23.
//

import UIKit

class FranchiseModel : NSObject, Codable {
    
    var uid : String?
    var name : String?
    var email : String?
    var password : String?
    var image : String?
    var address : String?
    var latitude : Double?
    var longitude : Double?
    var createDate : Date?
    var geoHash : String?
    var about : String?
    
    var totalFundraiserEarning : Int?
    var totalBusinessEarning : Int?
    
    static func clean() {
        franchiseModel = nil
    }
    private static var franchiseModel : FranchiseModel?
     
      static var data : FranchiseModel? {
          set(franchiseData) {
              if franchiseModel == nil {
                  self.franchiseModel = franchiseData
              }
          }
          get {
              return franchiseModel
          }
      }


      override init() {
          
      }
}
