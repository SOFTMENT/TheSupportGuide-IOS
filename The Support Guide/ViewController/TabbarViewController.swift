//
//  TabbarViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 28/04/23.
//


import UIKit
import Firebase

class TabbarViewController : UITabBarController, UITabBarControllerDelegate {
  
    var tabBarItems = UITabBarItem()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate  = self

        
        let selectedImage1 = UIImage(named: "home-10")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage1 = UIImage(named: "home-9")?.withRenderingMode(.alwaysOriginal)
        tabBarItems = self.tabBar.items![0]
        
        tabBarItems.image = deSelectedImage1
        tabBarItems.selectedImage = selectedImage1
        
        let selectedImage2 = UIImage(named: "navigator-2")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage2 = UIImage(named: "navigator")?.withRenderingMode(.alwaysOriginal)
        tabBarItems = self.tabBar.items![1]
        tabBarItems.image = deSelectedImage2
        tabBarItems.selectedImage = selectedImage2
        
        let selectedImage3 = UIImage(named: "star-4")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage3 = UIImage(named: "star-3")?.withRenderingMode(.alwaysOriginal)
        tabBarItems = self.tabBar.items![2]
        tabBarItems.image = deSelectedImage3
        tabBarItems.selectedImage = selectedImage3
        
        
        let selectedImage4 = UIImage(named: "user-23")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage4 = UIImage(named: "user-22")?.withRenderingMode(.alwaysOriginal)
        tabBarItems = self.tabBar.items![3]
        tabBarItems.image = deSelectedImage4
        tabBarItems.selectedImage = selectedImage4
    
        
        selectedIndex = 0
        

        if let user = FirebaseStoreManager.auth.currentUser {
            if !user.isAnonymous {
                self.updateFCMToken()
            }
        }
        else {
            DispatchQueue.main.async {
                self.logout()
            }
        }
 
        if #available(iOS 13, *) {
            let appearance = UITabBarAppearance()
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(red: 247/255, green: 79/255, blue: 85/255, alpha: 1)]
            tabBar.standardAppearance = appearance
            // Update for iOS 15, Xcode 13
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = appearance
            }
        }

      
        getAllCategories { categoriesModel in
            CategoryModel.catModels.append(contentsOf: categoriesModel)
        }
    }
    
    func selectTabbarIndex(position : Int){
        selectedIndex = position
    }


    func updateFCMToken(){
        if let user = Auth.auth().currentUser {
            UserModel.data?.notificationToken = Messaging.messaging().fcmToken
            Firestore.firestore().collection("Users").document(user.uid).setData(["notificationToken" : Messaging.messaging().fcmToken ?? ""], merge: true)
        }
       
    }
    
    
 
    
}


