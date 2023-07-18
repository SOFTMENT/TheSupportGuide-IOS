//
//  UserModel.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 26/04/23.
//

import UIKit
import Foundation


class UserModel: NSObject, Codable {
    
    var fullName : String?
    var email : String?
    var profilePic : String?
    var uid : String?
    var registredAt : Date?
    var regiType : String?
    var phoneNumber : String?
    var hasReferralCodeRedeemed : Bool?
    var notificationToken : String?
    var customer_id_stripe : String?
    var expireDate : Date?
    var isAdmin : Bool?
    var userType : String?
    static func clean() {
        userModel = nil
    }
    
    private static var userModel : UserModel?
     
      static var data : UserModel? {
          set(userData) {
              if userModel == nil {
                  self.userModel = userData
              }
            
          }
          get {
              return userModel
          }
      }


      override init() {
          
      }
}
