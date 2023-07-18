//
//  NotificationModel.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 09/05/23.
//

import UIKit

class NotificationModel: NSObject, Codable {
    
    var title : String?
    var message : String?
    var notificationTime : Date?
    var notificationId : String?
}
