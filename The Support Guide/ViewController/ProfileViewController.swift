//
//  ProfileViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 28/04/23.
//

import UIKit
import CropViewController
import StoreKit
import SDWebImage
import Lottie

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var annonymusView: UIView!
    @IBOutlet weak var loginAnimation: LottieAnimationView!
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var logoutView: UIView!


    @IBOutlet weak var loggedInView: UIView!
    @IBOutlet weak var favView: UIView!
    @IBOutlet weak var inviteFriendsView: UIView!
    @IBOutlet weak var rateAppView: UIView!
    @IBOutlet weak var helpCentreView: UIView!
    @IBOutlet weak var redeemHistory: UIView!
    @IBOutlet weak var tutorialView: UIView!
    
    @IBOutlet weak var notificationCentreView: UIView!
    @IBOutlet weak var version: UILabel!
    @IBOutlet weak var termsOfServiceView: UIView!
    @IBOutlet weak var privacyPolicyView: UIView!
    
    @IBOutlet weak var goPremiumImage: UIImageView!
    @IBOutlet weak var goPremiumView: UIView!
    @IBOutlet weak var goPremiumTitle: UILabel!
    
    @IBOutlet weak var annonymusVersion: UILabel!
    
    @IBOutlet weak var annonymusHelp: UIView!
    @IBOutlet weak var annonymusPrivacy: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var annonymusTermsOfService: UIView!
    override func viewDidLoad() {
        
        
        guard let currentUser = FirebaseStoreManager.auth.currentUser else {
            DispatchQueue.main.async {
                self.logout()
            }
            return
        }
        
        if currentUser.isAnonymous {
            loggedInView.removeFromSuperview()
            
            loggedInView.isHidden = true
            annonymusView.isHidden = false
            
            
            loginBtn.layer.cornerRadius = 8
            loginAnimation.loopMode = .loop
            loginAnimation.play()
            
            loginBtn.isUserInteractionEnabled = true
            loginBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loginBtnClicked)))
            
            let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
            annonymusVersion.text  = "\(appVersion ?? "1.0")"
            
            annonymusHelp.isUserInteractionEnabled  = true
            annonymusHelp.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(helpCentreBtnClicked)))
            
            annonymusPrivacy.isUserInteractionEnabled = true
            annonymusPrivacy.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(privacyPolicyBtnClicked)))
            
            annonymusTermsOfService.isUserInteractionEnabled = true
            annonymusTermsOfService.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(termsOfServicesBtnClicked)))
        }
        else {
          
            loggedInView.isHidden = false
            annonymusView.isHidden = true
            
            tutorialView.isHidden = true
            tutorialView.isUserInteractionEnabled = true
            tutorialView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(tutorialViewClicked)))
            
            profilePic.layer.cornerRadius = 8
            profilePic.isUserInteractionEnabled = true
            profilePic.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewClicked)))
            if let path = UserModel.data!.profilePic, !path.isEmpty {
                profilePic.sd_setImage(with: URL(string: path), placeholderImage: UIImage(named: "profile-placeholder"))
            }
            
            userName.text =  UserModel.data!.fullName ?? ""
            
            goPremiumView.layer.cornerRadius = 8
            
            deleteView.isUserInteractionEnabled = true
            deleteView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteAccountBtnClicked)))
            
            favView.isUserInteractionEnabled = true
            favView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(favoriteBtnClicked)))
            
            notificationCentreView.isUserInteractionEnabled = true
            notificationCentreView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(notificationCentreClicked)))
            
            redeemHistory.isUserInteractionEnabled = true
            redeemHistory.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(redeemHistoryClicked)))
            
            helpCentreView.isUserInteractionEnabled = true
            helpCentreView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(helpCentreBtnClicked)))
            
            rateAppView.isUserInteractionEnabled = true
            rateAppView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rateAppBtnClicked)))
            
            inviteFriendsView.isUserInteractionEnabled = true
            inviteFriendsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(inviteFriendsBtnClicked)))
            
            privacyPolicyView.isUserInteractionEnabled = true
            privacyPolicyView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(privacyPolicyBtnClicked)))
            
            termsOfServiceView.isUserInteractionEnabled = true
            termsOfServiceView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(termsOfServicesBtnClicked)))
            
            
            self.logoutView.isUserInteractionEnabled = true
            self.logoutView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(logoutBtnClicked)))
            
            let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
            version.text  = "\(appVersion ?? "1.0")"
            
        
            let daysleft = self.membershipDaysLeft(currentDate: Constants.currentDate, expireDate: UserModel.data!.expireDate ?? Date()) + 1
               if daysleft > 1 {
                   self.goPremiumTitle.text = "\(daysleft) Days Left"
               }
               else {
                   
                   self.goPremiumTitle.text = "\(daysleft) Day Left"
                   
               }
               self.goPremiumImage.image = UIImage(named: "clock")
        }
      
      
    }
    
    @objc func tutorialViewClicked(){
        
    }
    
    @objc func loginBtnClicked(){
        self.logout()
    }
    
    @objc func deleteAccountBtnClicked(){
        let alert = UIAlertController(title: "DELETE ACCOUNT", message: "Are you sure you want to delete your account?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            
            if let user = FirebaseStoreManager.auth.currentUser {
                
                self.ProgressHUDShow(text: "Account Deleting...")
                let userId = user.uid
                
                FirebaseStoreManager.db.collection("Users").document(userId).delete { error in
                    
                    if error == nil {
                        user.delete { error in
                            self.ProgressHUDHide()
                            if error == nil {
                                self.logout()
                                
                            }
                            else {
                                self.beRootScreen(mIdentifier: Constants.StroyBoard.entryViewController)
                            }
                            
                            
                        }
                        
                    }
                    else {
                        
                        self.showError(error!.localizedDescription)
                    }
                }
                
            }
            
            
        }))
        present(alert, animated: true)
    }
    
    
    
    
    @objc func logoutBtnClicked(){
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.logout()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    @objc func favoriteBtnClicked(){
        if let tabBarController = tabBarController as? TabbarViewController {
            tabBarController.selectTabbarIndex(position: 2)
        }
    }
    
    @objc func notificationCentreClicked(){
       performSegue(withIdentifier: "notificationsSeg", sender: nil)
    }
 
    
    @objc func redeemHistoryClicked(){
        
     performSegue(withIdentifier: "redeemHistorySeg", sender: nil)
    }
    
    @objc func helpCentreBtnClicked(){
        
        if let url = URL(string: "mailto:432solar@gmail.com") {
            let application:UIApplication = UIApplication.shared
                if (application.canOpenURL(url)) {
                    application.open(url, options: [:], completionHandler: nil)
                }
        }
    }
    
    @objc func rateAppBtnClicked(){
        if let url = URL(string: "itms-apps://itunes.apple.com/app/" + "6448403451") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc func inviteFriendsBtnClicked(){
        let someText:String = "Check Out The Support Guide App Now."
        let objectsToShare:URL = URL(string: "https://apps.apple.com/us/app/the-support-guide/6448403451")!
        let sharedObjects:[AnyObject] = [objectsToShare as AnyObject,someText as AnyObject]
        let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func privacyPolicyBtnClicked(){
        
        guard let url = URL(string: "https://softment.in/privacy-policy/") else { return}
        UIApplication.shared.open(url)
        
    }
    
    @objc func termsOfServicesBtnClicked(){
        guard let url = URL(string: "https://softment.in/terms-of-service/") else { return}
        UIApplication.shared.open(url)
    }
    
    @objc func imageViewClicked(){
        chooseImageFromPhotoLibrary()
    }
    
    func chooseImageFromPhotoLibrary(){
        
        let alert = UIAlertController(title: "Upload Profile Picture", message: "", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Using Camera", style: .default) { (action) in
            
            let image = UIImagePickerController()
            image.title = "Profile Picture"
            image.delegate = self
            image.sourceType = .camera
            self.present(image,animated: true)
            
            
        }
        
        let action2 = UIAlertAction(title: "From Photo Library", style: .default) { (action) in
            
            let image = UIImagePickerController()
            image.delegate = self
            image.title = "Profile Picture"
            image.sourceType = .photoLibrary
            
            self.present(image,animated: true)
            
            
        }
        
        let action3 = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        
        self.present(alert,animated: true,completion: nil)
    }
    
    
    
    
    
}


extension ProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate,CropViewControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.originalImage] as? UIImage {
            

            self.dismiss(animated: true) {
                
                let cropViewController = CropViewController(image: editedImage)
                cropViewController.title = picker.title
                cropViewController.delegate = self
                cropViewController.customAspectRatio = CGSize(width: 1  , height: 1)
                cropViewController.aspectRatioLockEnabled = true
                cropViewController.aspectRatioPickerButtonHidden = true
                self.present(cropViewController, animated: true, completion: nil)
            }
            
            
            
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        self.ProgressHUDShow(text: "Updating...")
        
        profilePic.image = image
        
        uploadImageOnFirebase(uid : FirebaseStoreManager.auth.currentUser!.uid){ downloadURL in
            
            FirebaseStoreManager.db.collection("Users").document(FirebaseStoreManager.auth.currentUser!.uid).setData(["profilePic" : downloadURL], merge: true) { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                }
                else {
                    UserModel.data?.profilePic = downloadURL
                    self.showToast(message: "Profile pic has changed")
                }
            }
            
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func uploadImageOnFirebase(uid : String,completion : @escaping (String) -> Void ) {
        
        let storage = FirebaseStoreManager.storage.reference().child("ProfilePic").child(uid).child("\(uid).png")
        var downloadUrl = ""
        
        var uploadData : Data!
        
        
        uploadData = (self.profilePic.image?.jpegData(compressionQuality: 0.4))!
        
        
        
        storage.putData(uploadData, metadata: nil) { (metadata, error) in
            
            if error == nil {
                storage.downloadURL { (url, error) in
                    if error == nil {
                        downloadUrl = url!.absoluteString
                    }
                    completion(downloadUrl)
                    
                }
            }
            else {
                completion(downloadUrl)
            }
            
        }
    }
}
