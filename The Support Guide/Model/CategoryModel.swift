//
//  CategoryModel.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 29/04/23.
//

import UIKit

class CategoryModel : NSObject, Codable {
    
    var id : String?
    var catName : String?
    
    static var catModels : [CategoryModel] = []
    
}
