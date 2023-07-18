//
//  FranchiseProfileViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 22/05/23.
//

import UIKit
import StoreKit

class FranchiseProfileViewController : UIViewController {
    
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var mName: UILabel!
    @IBOutlet weak var mEmail: UILabel!
    @IBOutlet weak var logoutView: UIView!
    @IBOutlet weak var trainingView: UIView!
    @IBOutlet weak var goalsView: UIView!
    
    @IBOutlet weak var rateApp: UIView!
    @IBOutlet weak var inviteFriend: UIView!
    
    @IBOutlet weak var version: UILabel!
    @IBOutlet weak var privacyPolicy: UIView!
    @IBOutlet weak var termsOfService: UIView!
    
 

    override func viewDidLoad() {
        
        profilePic.layer.cornerRadius = 8
         if let path = FranchiseModel.data!.image, !path.isEmpty {
            profilePic.sd_setImage(with: URL(string: path), placeholderImage: UIImage(named: "profile-placeholder"))
        }
        
        editBtn.layer.cornerRadius = 8
        
        mName.text = FranchiseModel.data!.name ?? ""
        mEmail.text = FranchiseModel.data!.email ?? ""
        
        goalsView.isUserInteractionEnabled = true
        goalsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goalsClicked)))
        
        trainingView.isUserInteractionEnabled = true
        trainingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(trainingClicked)))
        
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        version.text  = "\(appVersion ?? "1.0")"
    
        rateApp.isUserInteractionEnabled = true
        rateApp.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rateAppBtnClicked)))
        
        inviteFriend.isUserInteractionEnabled = true
        inviteFriend.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(inviteFriendsBtnClicked)))
        
        privacyPolicy.isUserInteractionEnabled = true
        privacyPolicy.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(privacyPolicyBtnClicked)))
        
        termsOfService.isUserInteractionEnabled = true
        termsOfService.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(termsOfServicesBtnClicked)))
        
        self.logoutView.isUserInteractionEnabled = true
        self.logoutView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(logoutBtnClicked)))
    }
    
    @IBAction func editBtnClicked(_ sender: Any) {
        performSegue(withIdentifier: "franchiseeditFranchiseSeg", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "franchiseeditFranchiseSeg" {
            if let VC = segue.destination as? EditFranchiseViewController {
                VC.franchiseModel = FranchiseModel.data
            }
        }
    }
    
    @objc func goalsClicked(){
        performSegue(withIdentifier: "franchiseGoalSeg", sender: nil)
    }
    
    @objc func trainingClicked(){
        performSegue(withIdentifier: "franchiseTrainingSeg", sender: nil)
    }

    
    @objc func logoutBtnClicked(){
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.logout()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    @objc func rateAppBtnClicked(){
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else if let url = URL(string: "itms-apps://itunes.apple.com/app/" + "6448403451") {
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
}
