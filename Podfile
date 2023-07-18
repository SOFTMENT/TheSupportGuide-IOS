# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'The Support Guide' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for The Support Guide

  pod 'Firebase/Firestore'
  
   pod 'Firebase/Analytics'
   
   pod 'Firebase/DynamicLinks'
   
   pod 'Firebase/Auth'

   pod 'Firebase/Storage'
   
   pod 'Firebase/Messaging'

   pod 'FirebaseFirestoreSwift'

   pod 'FBSDKLoginKit'
   
   pod 'GoogleSignIn'
   
   pod 'MBProgressHUD'
   
   pod 'SDWebImage'

  pod 'CropViewController'
  
  pod 'IQKeyboardManagerSwift'

  pod 'MHLoadingButton'
  
 pod 'DropDown'
 
 pod 'TTGSnackbar'

 pod 'GooglePlaces'
 
 pod 'Stripe'
 
 pod 'StripePaymentSheet'
 
 pod 'lottie-ios'
 
 pod 'FirebaseFunctions'
 
 pod 'GeoFire/Utils'

 
 pod 'Cloudinary', '~> 3.0'
 
 pod 'ATGMediaBrowser'
end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end
end
