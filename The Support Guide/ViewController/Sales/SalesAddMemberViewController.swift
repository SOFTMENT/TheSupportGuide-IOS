//
//  SalesAddMemberViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 08/06/23.
//

import UIKit
import CropViewController

class SalesAddMemberViewController : UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var mProfile: UIImageView!
    @IBOutlet weak var mName: UITextField!
    @IBOutlet weak var addBtn: UIButton!
    var isImageSelected = false
    override func viewDidLoad() {
        
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        mProfile.layer.cornerRadius = 8
        mProfile.isUserInteractionEnabled = true
        mProfile.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewClicked)))
        
        addBtn.layer.cornerRadius = 8
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
       
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
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    
    @IBAction func addBtnClicked(_ sender: Any) {
        
        let sName = mName.text
        if sName == "" {
            self.showToast(message: "Please Enter Name")
        }
        else {
            self.ProgressHUDShow(text: "")
            let memberModel = SalesMemberModel()
            memberModel.createDate = Date()
            memberModel.fundraiserId = FundraiserModel.data!.uid
            memberModel.name = sName
            let collectionRef = FirebaseStoreManager.db.collection("Fundraisers").document(FundraiserModel.data!.uid ?? "123").collection("Members")
            let id = collectionRef.document().documentID
            memberModel.id = id
            
            if isImageSelected {
                self.uploadImageOnFirebase(uid: id) { downloadURL in
                    memberModel.profilePic = downloadURL
                    self.addMember(memberModel: memberModel)
                }

            }
            else {
                self.addMember(memberModel: memberModel)
            }
        }
        
    }
    func addMember(memberModel : SalesMemberModel){
        try? FirebaseStoreManager.db.collection("Fundraisers").document(FundraiserModel.data!.uid ?? "123").collection("Members").document(memberModel.id ?? "1234").setData(from: memberModel, completion: { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                self.showToast(message: "Member Added")
                let seconds = 2.5
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                    self.dismiss(animated: true)
                }
            }
        })
    }
}

extension SalesAddMemberViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}
extension SalesAddMemberViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate,CropViewControllerDelegate {
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
        
        let storage = FirebaseStoreManager.storage.reference().child("SalesMembersProfileImage").child(uid).child("\(uid).png")
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
