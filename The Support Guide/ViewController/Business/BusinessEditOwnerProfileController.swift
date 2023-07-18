//
//  BusinessEditOwnerProfileController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 02/06/23.
//

import UIKit
import CropViewController

class BusinessEditOwnerProfileController : UIViewController {
    
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var mProfile: UIImageView!
    @IBOutlet weak var mAbout: UITextView!
    @IBOutlet weak var mName: UITextField!
    var isImageSelected = false
    @IBOutlet weak var socialMediaURL1: UITextField!
    @IBOutlet weak var socialMediaURL2: UITextField!
    @IBOutlet weak var socialMediaURL3: UITextField!
    
    
    
    override func viewDidLoad() {
        
        updateBtn.layer.cornerRadius = 8
        
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        mProfile.makeRounded()
        mProfile.isUserInteractionEnabled = true
        mProfile.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewClicked)))
        
        mAbout.layer.cornerRadius = 8
        mAbout.layer.borderWidth = 1
        mAbout.layer.borderColor = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1).cgColor
        mAbout.contentInset = UIEdgeInsets(top: 6, left: 5, bottom: 6, right: 6)
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        mName.delegate = self
        
        socialMediaURL1.delegate = self
        socialMediaURL2.delegate = self
        socialMediaURL3.delegate = self
        
        ProgressHUDShow(text: "")
        FirebaseStoreManager.db.collection("Businesses").document(B2BModel.data!.uid ?? "123").collection("Owner").document(B2BModel.data!.uid ?? "123").getDocument { snapshot, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                if let snapshot = snapshot, snapshot.exists {
                    if let ownerModel = try? snapshot.data(as: OwnerModel.self) {
                        if let path = ownerModel.profilePic, !path.isEmpty {
                            self.isImageSelected = true
                            self.mProfile.sd_setImage(with: URL(string: path), placeholderImage: UIImage(named: "profile-placeholder"))
                        }
                        self.mAbout.text = ownerModel.about ?? ""
                        self.mName.text = ownerModel.name ?? ""
                        self.socialMediaURL1.text = ownerModel.socialMediaURL1 ?? ""
                        self.socialMediaURL2.text = ownerModel.socialMediaURL2 ?? ""
                        self.socialMediaURL3.text = ownerModel.socialMediaURL3 ?? ""
                    }
                }
            }
        }
        
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    
    @IBAction func updateBtnClicked(_ sender: Any) {
        let sName = mName.text
        let sAbout = mAbout.text
        
        if !isImageSelected {
            self.showToast(message: "Upload Profile Picture")
        }
        else if sName == "" {
            self.showToast(message: "Enter Name")
        }
        else if sAbout == "" {
            self.showToast(message: "Enter About")
        }
        
        let ownerModel = OwnerModel()
        ownerModel.about = sAbout
        ownerModel.businessId = B2BModel.data!.uid
        ownerModel.name = sName
        ownerModel.socialMediaURL1 = self.socialMediaURL1.text
        ownerModel.socialMediaURL2 = self.socialMediaURL2.text
        ownerModel.socialMediaURL3 = self.socialMediaURL3.text
        self.ProgressHUDShow(text: "")
        self.uploadImageOnFirebase(uid: B2BModel.data!.uid ?? "123") { downloadURL in
            ownerModel.profilePic = downloadURL
            
            try? FirebaseStoreManager.db.collection("Businesses").document(B2BModel.data!.uid ?? "123").collection("Owner").document(B2BModel.data!.uid ?? "123").setData(from: ownerModel,merge : true,completion: { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                }
                else {
                    B2BModel.data!.hasOwnerProfile = true
                    FirebaseStoreManager.db.collection("Businesses").document(B2BModel.data!.uid ?? "123").setData(["hasOwnerProfile" : true],merge : true)
                    self.showToast(message: "Profile Updated")
                }
            })
            
        }
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


extension BusinessEditOwnerProfileController : UIImagePickerControllerDelegate, UINavigationControllerDelegate,CropViewControllerDelegate {
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
        
            isImageSelected = true
            mProfile.image = image
            self.dismiss(animated: true, completion: nil)
    }
    
    
    func uploadImageOnFirebase(uid : String,completion : @escaping (String) -> Void ) {
        
        let storage = FirebaseStoreManager.storage.reference().child("B2BOwner").child(uid).child("\(uid).png")
        var downloadUrl = ""
        
        var uploadData : Data!
        uploadData = (self.mProfile.image?.jpegData(compressionQuality: 0.5))!
        
    
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

extension BusinessEditOwnerProfileController : UITextFieldDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
        self.view.endEditing(true)
        return true
    }
    
}
