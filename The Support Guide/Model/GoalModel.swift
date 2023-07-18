//
//  GoalModel.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 19/05/23.
//

import UIKit

class GoalModel : NSObject, Codable{
    
    var id : String?
    var target : Int?
    var franchiseId : String?
    var finalDate : Date?
    var goalCreate : Date?
    var note : String?
    var type : String?
    var memberName : String?
    var memberId : String?
}
