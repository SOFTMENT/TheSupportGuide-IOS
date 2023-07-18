//
//  PipelineModel.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 21/05/23.
//

import UIKit

class PipelineModel : NSObject, Codable {
    
    var id : String?
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
    var createDate : Date?
    var type : String?
    var level : Int?
    

}
