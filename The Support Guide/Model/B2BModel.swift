//
//  B2BModel.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 20/05/23.
//

import UIKit

class B2BModel : NSObject, Codable {
    
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
    var openingTime : Date?
    var closingTime : Date?
    var email : String?
    var password : String?
    var amount : Int?
    var createDate : Date?
    var hasOwnerProfile : Bool?
    var expiryDate : Date?
    var catId : String?
    var catName : String?
    var googleBusinessLink : String?
    private static var b2bModel : B2BModel?
    static var b2bModels : [B2BModel] = []
    
    static func clean() {
        b2bModel = nil
        b2bModels.removeAll()
    }
    
      static var data : B2BModel? {
          set(b2bData) {
              if b2bModel == nil {
                  self.b2bModel = b2bData
              }
          }
          get {
              return b2bModel
          }
      }


      override init() {
          
      }
}
