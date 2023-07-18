//
//  ViewOwnerProfileViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 12/06/23.
//

import UIKit

class ViewOwnerProfileViewController : UIViewController {
    
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var userProfile: UIImageView!
    @IBOutlet weak var ownerName: UILabel!
    @IBOutlet weak var ownerAbout: UILabel!
    @IBOutlet weak var link3: UILabel!
    @IBOutlet weak var link3Stack: UIStackView!
    
    @IBOutlet weak var link2: UILabel!
    @IBOutlet weak var link2Stack: UIStackView!
    
    @IBOutlet weak var link1: UILabel!
    @IBOutlet weak var link1Stack: UIStackView!
    var b2bId : String?
    override func viewDidLoad() {
        
        guard let b2bId = b2bId else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        userProfile.layer.cornerRadius = 8
        
        ProgressHUDShow(text: "")
        FirebaseStoreManager.db.collection("Businesses").document(b2bId).collection("Owner").document(b2bId).getDocument { snapshot, error in
            self.ProgressHUDHide()
            if error != nil {
                self.dismiss(animated: true)
            }
            else {
                if let snapshot = snapshot, snapshot.exists {
                    if let ownerModel = try? snapshot.data(as: OwnerModel.self) {
                        if let path = ownerModel.profilePic, !path.isEmpty {
                          
                            self.userProfile.sd_setImage(with: URL(string: path), placeholderImage: UIImage(named: "profile-placeholder"))
                        }
                        self.ownerAbout.text = ownerModel.about ?? ""
                        self.ownerName.text = ownerModel.name ?? ""
                        
                        if let link1 = ownerModel.socialMediaURL1, !link1.isEmpty {
                            self.link1.text = link1
                            self.link1Stack.isHidden = false
                            
                            self.link1Stack.isUserInteractionEnabled = true
                            self.link1Stack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.link1Clicked)))
                        }
                        if let link2 = ownerModel.socialMediaURL2, !link2.isEmpty {
                            self.link2.text = link2
                            self.link2Stack.isHidden = false
                            
                            self.link2Stack.isUserInteractionEnabled = true
                            self.link2Stack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.link2Clicked)))
                        }
                        if let link3 = ownerModel.socialMediaURL3, !link3.isEmpty {
                            self.link3.text = link3
                            self.link3Stack.isHidden = false
                            
                            self.link3Stack.isUserInteractionEnabled = true
                            self.link3Stack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.link3Clicked)))
                        }
                    }
                }
                else {
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    @objc func link1Clicked(){
        guard let url = URL(string: makeValidURL(urlString: link1.text!)) else { return}
        UIApplication.shared.open(url)
    }
    @objc func link2Clicked(){
        guard let url = URL(string: makeValidURL(urlString: link2.text!)) else { return}
        UIApplication.shared.open(url)
    }
    @objc func link3Clicked(){
        guard let url = URL(string: makeValidURL(urlString: link3.text!)) else { return}
        UIApplication.shared.open(url)
    }
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
}
