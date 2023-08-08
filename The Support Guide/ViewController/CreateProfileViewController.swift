//
//  CreateProfileViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 27/04/23.
//

import UIKit
import Firebase
import CropViewController
import Stripe
import StripePayments
import StripeApplePay
import StripePaymentSheet
import PassKit

class CreateProfileViewController : UIViewController {
    var tip : Int = 0
    var isImageSelected = false
  
 
    @IBOutlet weak var personNameTF: UITextField!
    @IBOutlet weak var personNameView: UIView!
    @IBOutlet weak var fundraiserTF: UITextField!
    let fundRaiserPicker = UIPickerView()
    let personPicker = UIPickerView()
    var fundRaiserModels = Array<FundraiserModel>()
    var memberModels = Array<SalesMemberModel>()
    
    @IBOutlet weak var phoneNumber: UITextField!
    
    @IBOutlet weak var continueBtn: UIButton!
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var mainTipView: UIView!
    @IBOutlet weak var tipView: UIView!
    
    @IBOutlet weak var dollar2Btn: UIButton!
    @IBOutlet weak var dollar5Btn: UIButton!
    @IBOutlet weak var dollar7Btn: UIButton!
    @IBOutlet weak var dollar10Btn: UIButton!
    @IBOutlet weak var noTipBtn: UIButton!
    var clientSec : String?
    @IBOutlet weak var userName: UILabel!
    let goPremiumVC = GoPremiumViewController()
    var paymentSheet: PaymentSheet?
    var totalAmount = 0
    override func viewDidLoad() {
        
        guard UserModel.data != nil else {
            DispatchQueue.main.async {
                self.logout()
            }
            return
        }
        

        
        fundraiserTF.delegate = self
        fundRaiserPicker.delegate = self
        fundRaiserPicker.dataSource = self
        fundraiserTF.setRightIcons(icon: UIImage(named: "down-arrow")!)
        fundraiserTF.rightView?.isUserInteractionEnabled = true
        
        
        // ToolBar
        let selectFundraiserBar = UIToolbar()
        selectFundraiserBar.barStyle = .default
        selectFundraiserBar.isTranslucent = true
        selectFundraiserBar.tintColor = .link
        selectFundraiserBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(fundRaiserPickerDoneClicked))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(fundRaiserPickerCancelClicked))
        selectFundraiserBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        selectFundraiserBar.isUserInteractionEnabled = true
        fundraiserTF.inputAccessoryView = selectFundraiserBar
        fundraiserTF.inputView = fundRaiserPicker
        
        personNameTF.delegate = self
        personPicker.delegate = self
        personPicker.dataSource = self
        personNameTF.setRightIcons(icon: UIImage(named: "down-arrow")!)
        personNameTF.rightView?.isUserInteractionEnabled = true
        
        
        // ToolBar
        let selectPersonBar = UIToolbar()
        selectPersonBar.barStyle = .default
        selectPersonBar.isTranslucent = true
        selectPersonBar.tintColor = .link
        selectPersonBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton1 = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(personPickerDoneClicked))
        let spaceButton1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton1 = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(personPickerCancelClicked))
        selectPersonBar.setItems([cancelButton1, spaceButton1, doneButton1], animated: false)
        selectPersonBar.isUserInteractionEnabled = true
        personNameTF.inputAccessoryView = selectPersonBar
        personNameTF.inputView = personPicker
        
        self.ProgressHUDShow(text: "")
        getAllFundraiser { fundRaiserModels, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                self.fundRaiserModels.removeAll()
                let fundRaiserModel = FundraiserModel()
                fundRaiserModel.name = "No Fundraiser"
                fundRaiserModel.uid = nil
                self.fundRaiserModels.append(fundRaiserModel)
                self.fundRaiserModels.append(contentsOf: fundRaiserModels ?? [])
                self.fundRaiserPicker.reloadAllComponents()
            }
        }
        
        profilePic.makeRounded()
        profilePic.isUserInteractionEnabled = true
        profilePic.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewClicked)))
        
        userName.text = "Hello, \(UserModel.data!.fullName ?? "")"
      
        dollar2Btn.layer.cornerRadius = 8
        
       
        dollar5Btn.layer.cornerRadius = 8
        
       
        dollar7Btn.layer.cornerRadius = 8
        
        
        dollar10Btn.layer.cornerRadius = 8
        
        noTipBtn.layer.cornerRadius = 8
        noTipBtn.layer.borderColor = UIColor.black.cgColor
        noTipBtn.layer.borderWidth = 1
        
        tipView.layer.cornerRadius = 12
        
        phoneNumber.delegate = self
       
        
        continueBtn.layer.cornerRadius = 8
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        
        //CreateStripeCustomer
        self.createCustomerForStripe(name: UserModel.data!.fullName ?? "TheSupportGuide", email: UserModel.data!.email ?? "help@thesupportguide.com") { customer_id, error in
            if let customer_id = customer_id {
                UserModel.data?.customer_id_stripe = customer_id
                Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid).setData(["customer_id_stripe" : customer_id],merge: true)
            }
        }
    }
    
    @objc func fundRaiserPickerDoneClicked(){
        
        personNameTF.text = ""
        
       fundraiserTF.resignFirstResponder()
        let row = fundRaiserPicker.selectedRow(inComponent: 0)
        
        if row < 0 || fundRaiserModels.isEmpty {
            return
        }
        
        self.personNameView.isHidden = row == 0 ? true : false
        
        ProgressHUDShow(text: "")
        self.getAllFundraiserMembers(fundraiserId: self.fundRaiserModels[row].uid ?? "123") { memberModels, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                self.memberModels.removeAll()
                self.memberModels.append(contentsOf: memberModels ?? [])
                self.personPicker.reloadAllComponents()
            }
        }
        
        fundraiserTF.text = self.fundRaiserModels[row].name ?? "ERROR"
    }
    
    @objc func fundRaiserPickerCancelClicked(){
        fundraiserTF.resignFirstResponder()
    }
    @objc func personPickerDoneClicked(){
        
        
        
        
        personNameTF.resignFirstResponder()
        let row = personPicker.selectedRow(inComponent: 0)
        
        if memberModels.count > 0 {
            personNameTF.text = memberModels[row].name ?? ""
        }
      
        
       
    }
    
    @objc func personPickerCancelClicked(){
        personNameTF.resignFirstResponder()
    }
    func activateBtnClicked(){
        if let customerId = UserModel.data!.customer_id_stripe, !customerId.isEmpty {
            self.ProgressHUDShow(text: "")
    
            let total = 40 + tip
            self.totalAmount = total
            
            self.createPaymentIntentForStripe(amount: String(total * 100), currency: "USD", customer: customerId, email: UserModel.data!.email ?? "support@softment.in") { client_secret, secret in
                DispatchQueue.main.async {
                    self.ProgressHUDHide()
                }
                if let client_secret = client_secret,
                    let secret = secret{
                  
                    self.clientSec = client_secret
                    
                        DispatchQueue.main.async {
                            if self.goPremiumVC.creditDebitCheck.isSelected {
                            var configuration = PaymentSheet.Configuration()
                               configuration.merchantDisplayName = "The Support Guide"
                               configuration.customer = .init(id: customerId, ephemeralKeySecret: secret)
                               // Set `allowsDelayedPaymentMethods` to true if your business can handle payment
                               // methods that complete payment after a delay, like SEPA Debit and Sofort.
                               configuration.allowsDelayedPaymentMethods = true
                               self.paymentSheet = PaymentSheet(paymentIntentClientSecret: client_secret, configuration: configuration)
                          self.paymentSheet?.present(from: self) { paymentResult in
                             // MARK: Handle the payment result
                              switch paymentResult {
                             case .completed:
                                  self.add1YearMembership()
                                 
                             case .failed(let error):
                                  self.showMessage(title: "Payment Failed", message: error.localizedDescription)
                              case .canceled:
                                  print("Payment Cancelled")
                              }
                           }
                        }
                            else {
                                self.handleApplePay(amount: total, delegate: self)
                            }
                    }
            
                }
                else {
                    self.showError("payment id not found.")
                }

            }
           
            
        }
        else{
            self.showError("Customer id not found.")
        }
    }
  
    
    func showPaymentScreen(tip : Int){
        self.mainTipView.isHidden = true
        self.tip = tip
        self.goPremiumVC.modalPresentationStyle = .custom
        self.goPremiumVC.transitioningDelegate = self
        self.present(self.goPremiumVC, animated: true, completion: nil)
    }
    
    @IBAction func dollar2Clicked(_ sender: Any) {
        showPaymentScreen(tip: 2)
    }
    
    @IBAction func dollar5Clicked(_ sender: Any) {
        showPaymentScreen(tip: 5)
    }
    
    @IBAction func dollar7Clicked(_ sender: Any) {
        showPaymentScreen(tip: 7)
    }
    
    @IBAction func dollar10Clicked(_ sender: Any) {
        showPaymentScreen(tip: 10)
    }
    
  
    
    @IBAction func noTipClicked(_ sender: Any) {
        showPaymentScreen(tip: 0)
    }
    
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    
    func add1YearMembership(){
        ProgressHUDShow(text: "")

        let futureDate = self.addYearToDate(years: 1, currentDate: Date())
        
        let batch = FirebaseStoreManager.db.batch()
        let personIndex = personPicker.selectedRow(inComponent: 0)
        if personNameTF.text != "" && personIndex > -1 {
            let memberVC =  FundraiserTransactionModel()
            memberVC.amount = self.totalAmount
            memberVC.date = Date()
            memberVC.fundraiserId = self.memberModels[personIndex].fundraiserId
            memberVC.userId = UserModel.data!.uid
            memberVC.userImage = UserModel.data!.profilePic
            memberVC.userName = UserModel.data!.fullName
            memberVC.memberId = self.memberModels[personIndex].id
            let collectionRef = Firestore.firestore().collection("FundraiserTransactions")
            memberVC.id = collectionRef.document().documentID
            try! batch.setData(from: memberVC, forDocument: collectionRef.document(memberVC.id!))
            
            let saleMember = self.memberModels[personIndex]
            batch.setData(["totalSaleUpdate" : Date(), "totalSales" : FieldValue.increment(Int64(1))], forDocument: Firestore.firestore().collection("Fundraisers").document(saleMember.fundraiserId ?? "123").collection("Members").document(saleMember.id ?? "123"),merge: true)
            
            let fundraiserModel = self.fundRaiserModels[fundRaiserPicker.selectedRow(inComponent: 0)]
            batch.setData(["totalEarning" : FieldValue.increment(Int64(self.totalAmount)), "totalSales" : FieldValue.increment(Int64(1))], forDocument: Firestore.firestore().collection("Fundraisers").document(saleMember.fundraiserId ?? "123"),merge: true)
            
            batch.setData(["totalFundraiserEarning" : FieldValue.increment(Int64(self.totalAmount))], forDocument: Firestore.firestore().collection("Franchises").document(fundraiserModel.franchiseId ?? "123"),merge: true)
        }
        
        batch.setData(["expireDate" : futureDate], forDocument: Firestore.firestore().collection("Users").document(UserModel.data!.uid ?? "123"), merge: true)
        batch.commit { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                UserModel.data!.expireDate = futureDate
                self.performSegue(withIdentifier: "successSeg", sender: nil)
            }
        }
      
    }
    
    
    @IBAction func continueBtnClicked(_ sender: Any) {
        let sPhoneNumber = phoneNumber.text
        let sFundraiser = fundraiserTF.text
        let sPersonName = personNameTF.text
        if sPhoneNumber == "" {
            self.showToast(message: "Enter Phone Number")
        }
        else if sFundraiser == "" {
            self.showToast(message: "Select Fundraiser")
        }
        else if fundRaiserPicker.selectedRow(inComponent: 0) > 0 && sPersonName == "" {
            self.showToast(message: "Select Person")
        }
        else {
            view.endEditing(true)
            self.ProgressHUDShow(text: "")
            UserModel.data?.phoneNumber = sPhoneNumber
            
            if isImageSelected {
                self.uploadImageOnFirebase(uid: UserModel.data!.uid ?? "") { downloadURL in
                    UserModel.data?.profilePic = downloadURL
                    self.updateUser()
                }
            }
            else {
                self.updateUser()
            }
            
           
        }
    }
    
    func updateUser(){
        try? Firestore.firestore().collection("Users").document(UserModel.data!.uid ?? "123").setData(from: UserModel.data!, merge : true, completion: { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                if self.fundRaiserPicker.selectedRow(inComponent: 0) > 0 {
                    self.mainTipView.isHidden = false
                }
                else {
                    self.showPaymentScreen(tip: 0)
                }
            
            }
        })
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


extension CreateProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate,CropViewControllerDelegate {
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
            profilePic.image = image
            self.dismiss(animated: true, completion: nil)
    }
    
    
    func uploadImageOnFirebase(uid : String,completion : @escaping (String) -> Void ) {
        
        let storage = Storage.storage().reference().child("ProfilePicture").child(uid).child("\(uid).png")
        var downloadUrl = ""
        
        var uploadData : Data!
        uploadData = (self.profilePic.image?.jpegData(compressionQuality: 0.5))!
        
    
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
extension CreateProfileViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.hideKeyboard()
        return true
    }
}
extension CreateProfileViewController : UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {


      
        return GoPremiumPresentationViewController(presentedViewController: presented, presenting: presenting,createProfile: self)
        



    }

    
}

extension CreateProfileViewController : ApplePayContextDelegate {
    func applePayContext(_ context: StripeApplePay.STPApplePayContext, didCompleteWith status: StripeApplePay.STPApplePayContext.PaymentStatus, error: Error?) {
        switch status {
      case .success:
            self.add1YearMembership()
      
          break
      case .error:
            self.showMessage(title: "Payment Failed", message: error!.localizedDescription)
          break
      case .userCancellation:
          // User canceled the payment
          break
     
      }
    }
    
   
   
    
  
    func applePayContext(_ context: STPApplePayContext, didCreatePaymentMethod paymentMethod: StripeAPI.PaymentMethod, paymentInformation: PKPayment, completion: @escaping STPIntentClientSecretCompletionBlock) {
        
       completion(clientSec, nil)
        
    }

        
    
}
extension CreateProfileViewController : UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == fundRaiserPicker {
            return self.fundRaiserModels.count
        }
        else {
            return self.memberModels.count
        }
         
        

    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        if pickerView == fundRaiserPicker {
            return fundRaiserModels[row].name ?? ""
        }
        else {
            return self.memberModels[row].name ?? ""
        }
        
    }

}
