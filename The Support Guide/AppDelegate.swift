//
//  AppDelegate.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 26/04/23.
//


import UIKit
import IQKeyboardManagerSwift
import GoogleSignIn
import Firebase
import FirebaseMessaging
import FBSDKCoreKit
import GooglePlaces
import Stripe
import Cloudinary

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    var body = "message"
    var title = "Title"
    open var cloudinary: CLDCloudinary!
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
     
        if error != nil {
            
            return
      }

       
    }


    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    // This method handles opening custom URL schemes (for example, "your-app://stripe-redirect")
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let stripeHandled = StripeAPI.handleURLCallback(with: url)
        if (stripeHandled) {
            return true
        } else {
            // This was not a Stripe url – handle the URL normally as you would
        }
        return false
    }
    // This method handles opening universal link URLs (for example, "https://example.com/stripe_ios_callback")
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool  {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                let stripeHandled = StripeAPI.handleURLCallback(with: url)
                if (stripeHandled) {
                    return true
                } else {
                    // This was not a Stripe url – handle the URL normally as you would
                }
            }
        }
        return false
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
     
        ApplicationDelegate.shared.application(
                    application,
                    didFinishLaunchingWithOptions: launchOptions
                )
        
        
       
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }
        
        
        GMSPlacesClient.provideAPIKey("AIzaSyA0s1sqV20wmXHfso3aF1Zl9b2Skw53SsY")
       
        Constants.isLive = false
        
        if Constants.isLive {
            StripeAPI.defaultPublishableKey = "pk_live_51JplP2DbCahGDE6gsZHMLxyoOQePh7znNAUt84YuBmXjDyn0jVxIM1PosTmJczzVT7gqqNMhpd6Db4W2P0KkQdqC00bDOpOxV0"
        }
        else {
            StripeAPI.defaultPublishableKey = "pk_test_51MxtoYFR1aAk6lQtMx13u63UQHm5dpGZfzYirN1xreBTF4cGi3lANngO1gDyGgrHDbMJTucYI3sHULXhFvvsp5QW00e7XjolYR"
        }
        
        let config = CLDConfiguration(cloudName: "dgfmmcvpf", apiKey: "772995444379722",apiSecret: "r0RShyg5xTg03-01I_BpA1YyMtA")
        cloudinary = CLDCloudinary(configuration: config)
        
        application.registerForRemoteNotifications()
       
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
       
        //FirebaseOptions.defaultOptions()?.deepLinkURLScheme =
        IQKeyboardManager.shared.enable = true
        FirebaseApp.configure()

        Auth.auth().addStateDidChangeListener { auth, user in
            if user == nil {
                FundraiserModel.clean()
                FranchiseModel.clean()
                UserModel.clean()
                B2BModel.clean()
            }
        }
        return true
    }
    
  
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        let ui =  UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
      
      
       
        
        return ui
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
  
    

}

extension AppDelegate : MessagingDelegate {
    
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
     

               
      let dataDict:[String: String] = ["token": fcmToken ?? "123"]
      NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
      // TODO: If necessary send token to application server.
      // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
 
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // Print message ID.
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID: \(messageID)")
    }

    // Print full message.
    print(userInfo)

    // Change this to your preferred presentation option
    if #available(iOS 14.0, *) {
        completionHandler([.banner, .list,.sound])
    } else {
        completionHandler([.alert])
    }
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo

    // Print message ID.
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID: \(messageID)")
    }


  
    let aps = userInfo["aps"] as? NSDictionary
       if let aps = aps {
          let alert = aps["alert"] as! NSDictionary
            body = alert["body"] as! String
            title = alert["title"] as! String
       }

   
    completionHandler()
  }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)
        
      // Print message ID.
   
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }

      // Print full message.
      print(userInfo)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }

      // Print full message.
      print(userInfo)

      completionHandler(UIBackgroundFetchResult.newData)
    }
    
  
}


