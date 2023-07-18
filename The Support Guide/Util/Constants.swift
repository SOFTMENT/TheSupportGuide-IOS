//
//  Constants.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 26/04/23.
//

import Foundation
import UIKit
import CoreLocation

struct Constants {
   
    
    
    struct StroyBoard {
        
        static let signInViewController = "signInVC"
        static let homeViewController = "homeVC"
        static let tabBarViewController = "tabbarVC"
        static let entryViewController = "entryVC"
        static let signUpViewController = "signUpVC"
        static let createProfileViewController = "createProfileVC"
        static let adminTabBarViewController = "adminTabbarVC"
        static let franchiseTabbarViewController = "franchiseTabbarVC"
        static let businessTabbarViewController = "businessTabbarVC"
        static let fundraiserTabbarViewController = "fundraiserTabbarVC"
        
      
    }
    
    static var clLocation : CLLocation = CLLocation(latitude: 31.353637, longitude: -107.402344)
    public static var currentDate = Date()
    public static var expireDate = Date()
    public static var subscriptionStatus = ""
    public static var interval = ""
    public static var isLive = true
    public static let BASE_URL = "https://softment.in/the_support_guide/stripe/"
    public static let APPLE_MERCHANT_ID = "merchant.com.thesupportguide"
    public static let INTREST_LEVEL  = ["1","2","3","4","5","6","7","8","9","10"]
    public static let persons = ["John","Vijay"]
}


