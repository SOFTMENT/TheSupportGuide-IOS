//
//  FundraiserModel.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 28/04/23.
//

import UIKit

class FundraiserModel : NSObject, Codable {
    
    var uid : String?
    var name : String?
    var franchiseId : String?
    var aboutBusiness : String?
    var image : String?
    var address : String?
    var latitude : Double?
    var longitude : Double?
    var geoHash : String?
    var phoneNumber : String?
    var email : String?
    var password : String?
    var createDate : Date?
    var totalEarning : Int?
    var totalSales : Int?
    private static var fundraiserModel : FundraiserModel?
   
    static func clean() {
        fundraiserModel = nil
    }
      static var data : FundraiserModel? {
          set(fundraiserData) {
              if fundraiserModel == nil {
                  self.fundraiserModel = fundraiserData
              }
          }
          get {
              return fundraiserModel
          }
      }


      override init() {
          
      }
}
