//
//  FirebaseStoreManager.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 30/04/23.
//

import Firebase

struct FirebaseStoreManager {
    static let db = Firestore.firestore()
    static let auth = Auth.auth()
    static let storage = Storage.storage()
}

