//
//  BusinessAddVoucherViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 29/05/23.
//

import UIKit
import CropViewController

class BusinessAddVoucherViewController : UIViewController {
    @IBOutlet weak var imageStackView: UIStackView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var imageView: UIView!
    
    @IBOutlet weak var timesRedeemTF: UITextField!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var mTitle: UITextField!
    @IBOutlet weak var mConditions: UITextView!
    @IBOutlet weak var mOFF: UITextField!
    @IBOutlet weak var mValidUpto: UITextField!
    @IBOutlet weak var addBtn: UIButton!
    var isFree = true
    let datePicker = UIDatePicker()
    var isImageSelected = false
    
    override func viewDidLoad() {
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        mTitle.delegate = self
        mValidUpto.delegate = self
        mOFF.delegate = self
        
        timesRedeemTF.delegate = self
        
        mConditions.layer.cornerRadius = 8
        mConditions.layer.borderWidth = 1
        mConditions.layer.borderColor = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1).cgColor
        mConditions.contentInset = UIEdgeInsets(top: 6, left: 5, bottom: 6, right: 6)
        
        addBtn.layer.cornerRadius = 8
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributes, for: .selected)
        
        image.layer.cornerRadius = 8
        imageView.layer.cornerRadius = 8
        imageStackView.layer.cornerRadius = 8
        imageStackView.layer.borderWidth = 1
        imageStackView.layer.borderColor = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1).cgColor
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewClicked)))
        
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewClicked)))
        
        createDatePicker()
        
       
    }
    
  
    func createDatePicker() {
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }

        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(dateDoneBtnTapped))
        toolbar.setItems([done], animated: true)
        
        mValidUpto.inputAccessoryView = toolbar
        
        datePicker.datePickerMode = .date
        mValidUpto.inputView = datePicker
    }
    @objc func dateDoneBtnTapped() {
        view.endEditing(true)
        let selectedDate = datePicker.date
        self.mValidUpto.text = convertDateFormater(selectedDate)
    }
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
    @IBAction func segmentClicked(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            isFree = true
            self.mOFF.isHidden = true
        }
        else {
            self.mOFF.isHidden = false
            isFree = false
        }
    }
    
    @IBAction func addBtnClicked(_ sender: Any) {
        let sTitle = mTitle.text
        let sConditions = mConditions.text
        let sOFF = mOFF.text
        let sValid = mValidUpto.text
        let sTimes = timesRedeemTF.text
        
        if !isImageSelected {
            self.showToast(message: "Upload Picture")
        }
        else if sTitle == ""{
            self.showToast(message: "Enter title")
        }
        else if sTimes == "" {
            self.showToast(message: "Enter Times Redeemable")
        }
        else if sConditions == "" {
            self.showToast(message: "Enter conditions")
        }
        else if sOFF == "" && !isFree {
            self.showToast(message: "Enter OFF Percentage")
        }
        else if sValid == "" {
            self.showToast(message: "Selelct valid upto")
        }
        else {
            self.ProgressHUDShow(text: "")
            let voucherModel  = VoucherModel()
            voucherModel.added = Date()
            voucherModel.valid = self.datePicker.date
            voucherModel.title = sTitle
            voucherModel.conditions = sConditions
            voucherModel.isFree = isFree
            voucherModel.timesRedeemable = Int(sTimes!)
            voucherModel.businessUid = B2BModel.data!.uid
            if !isFree {
                voucherModel.discounts = Int(sOFF ?? "1")!
            }
            let id =  FirebaseStoreManager.db.collection("Businesses").document(voucherModel.businessUid ?? "123").collection("Vouchers").document().documentID
            voucherModel.id = id
            
            uploadImageOnFirebase(id: id) { downloadURL in
                voucherModel.mImage = downloadURL
                self.addVoucher(voucherModel: voucherModel) { isSuccess, error in
                    self.ProgressHUDHide()
                    if let error = error {
                        self.showError(error)
                    }
                    else {
                        self.showToast(message: "Voucher Added")
                        let seconds = 2.5
                        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                            self.dismiss(animated: true)
                        }
                    }
                }

            }
                
        }
    }
    
    @objc func imageViewClicked(){
        chooseImageFromPhotoLibrary()
    }
    func chooseImageFromPhotoLibrary(){
        
        let image = UIImagePickerController()
        image.delegate = self
        image.title = title
        image.sourceType = .photoLibrary
        self.present(image,animated: true)
    }
}
extension BusinessAddVoucherViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate,CropViewControllerDelegate {
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
        
      
        
        self.image.image = image
        self.image.isHidden = false
        imageView.isHidden = true
        self.isImageSelected = true
    

        self.dismiss(animated: true, completion: nil)
    }
    
    
    func uploadImageOnFirebase(id : String,completion : @escaping (String) -> Void ) {
        
        let storage = FirebaseStoreManager.storage.reference().child("OfferImages").child(id).child("\(id).png")
        var downloadUrl = ""
        
        var uploadData : Data!
        
        
        uploadData = (self.image.image?.jpegData(compressionQuality: 0.4))!
        
        
        
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
extension BusinessAddVoucherViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}
