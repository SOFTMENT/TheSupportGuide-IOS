//
//  FranchiseAddB2BViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 20/05/23.
//

import UIKit
import CropViewController
import CoreLocation
import GeoFire
import StripeApplePay
import StripePaymentSheet
import PassKit

class FranchiseAddB2BViewController : UIViewController {
    
    @IBOutlet weak var googleBusinessLink: UITextField!
    let catPicker = UIPickerView()
    @IBOutlet weak var categoryTF: UITextField!
    @IBOutlet weak var appleCheck: UIButton!
    @IBOutlet weak var creditCheck: UIButton!
    @IBOutlet weak var cashCheck: UIButton!
    @IBOutlet weak var cashView: UIStackView!
    @IBOutlet weak var appleView: UIStackView!
    @IBOutlet weak var creditView: UIStackView!
    @IBOutlet weak var backBtn: UIView!
    @IBOutlet weak var imageStackView: UIStackView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var mName: UITextField!
    @IBOutlet weak var mail: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var addBtn: UIButton!
    var isImageSelected = false
    @IBOutlet weak var fAddressTable: UITableView!
    @IBOutlet weak var fAbout: UITextView!
    @IBOutlet weak var fTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var fAddress: UITextField!
    var places : [Place] = []
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var isLocationSelected = false
    
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var openingTime: UITextField!
    @IBOutlet weak var closingTime: UITextField!
    @IBOutlet weak var enterAmount: UITextField!
    
    let openingDatePicker = UIDatePicker()
    let closingDatePicker = UIDatePicker()
    var clientSec : String?
    var customer_id_stripe : String?
    var paymentSheet: PaymentSheet?
    var b2bModel : B2BModel?
    var pipeLineModel : PipelineModel?
    var categoryModels = Array<CategoryModel>()
    var selectedCatModel : CategoryModel?
    override func viewDidLoad() {
        
        if let pipeLineModel = pipeLineModel {
            if let imagePath = pipeLineModel.image, !imagePath.isEmpty {
                
                self.image.isHidden = false
                imageView.isHidden = true
                isImageSelected = true
                image.sd_setImage(with: URL(string:imagePath), placeholderImage: UIImage(named: "profile-placeholder"))
            }
            mName.text = pipeLineModel.name ?? ""
            fAddress.text = pipeLineModel.address ?? ""
            latitude = pipeLineModel.latitude ?? 0.0
            longitude = pipeLineModel.longitude ?? 0.0
            isLocationSelected = true
            phoneNumber.text = pipeLineModel.phoneNumber
            openingTime.text = convertDateIntoTimeForRecurringVoucher(pipeLineModel.openingTime ?? Date())
            openingDatePicker.date = pipeLineModel.openingTime ?? Date()
            
            closingTime.text = convertDateIntoTimeForRecurringVoucher(pipeLineModel.closingTime ?? Date())
            closingDatePicker.date = pipeLineModel.closingTime ?? Date()
            
            fAbout.text = pipeLineModel.aboutBusiness ?? ""
            mail.text = pipeLineModel.email ?? ""
            
            
        }
        
        
        categoryTF.delegate = self
        catPicker.delegate = self
        catPicker.dataSource = self
        categoryTF.setRightIcons(icon: UIImage(named: "down-arrow")!)
        categoryTF.rightView?.isUserInteractionEnabled = true
        
        // ToolBar
        let catBar = UIToolbar()
        catBar.barStyle = .default
        catBar.isTranslucent = true
        catBar.tintColor = .link
        catBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton1 = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(catPickerDoneClicked))
        let spaceButton1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton1 = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(catPickerCancelClicked))
        catBar.setItems([cancelButton1, spaceButton1, doneButton1], animated: false)
        catBar.isUserInteractionEnabled = true
        categoryTF.inputAccessoryView = catBar
        categoryTF.inputView = catPicker
        
        image.layer.cornerRadius = 8
        imageView.layer.cornerRadius = 8
        imageStackView.layer.cornerRadius = 8
        imageStackView.layer.borderWidth = 1
        imageStackView.layer.borderColor = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1).cgColor
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewClicked)))
        
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewClicked)))
        
        mName.delegate = self
        phoneNumber.delegate = self
        enterAmount.delegate = self
        closingTime.delegate = self
        openingTime.delegate = self
    
        fAbout.layer.cornerRadius = 8
        fAbout.layer.borderWidth = 1
        fAbout.layer.borderColor = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1).cgColor
        fAbout.contentInset = UIEdgeInsets(top: 6, left: 5, bottom: 6, right: 6)
      
        fAddress.delegate = self
        fAddress.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        
        mail.delegate = self
        password.delegate = self
        googleBusinessLink.delegate = self
        
        addBtn.layer.cornerRadius = 8
        
        backBtn.isUserInteractionEnabled = true
        backBtn.layer.cornerRadius = 8
        backBtn.dropShadow()
        backBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        fAddressTable.delegate = self
        fAddressTable.dataSource = self
        fAddressTable.isScrollEnabled = false
        fAddressTable.contentInsetAdjustmentBehavior = .never
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        appleView.isUserInteractionEnabled = true
        appleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(applePayClicked)))
        
        creditView.isUserInteractionEnabled = true
        creditView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(creditDebitClicked)))
        
        cashView.isUserInteractionEnabled = true
        cashView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cashClicked)))
        
        createOpeningDatePicker()
        createClosingDatePicker()
        
        self.ProgressHUDShow(text: "")
        getAllCategories { categoriesModel in
            self.ProgressHUDHide()
            self.categoryModels.removeAll()
            self.categoryModels.append(contentsOf: categoriesModel)
            self.catPicker.reloadAllComponents()
        }
    }
    
    @objc func catPickerDoneClicked(){
        
        
        categoryTF.resignFirstResponder()
        let row = catPicker.selectedRow(inComponent: 0)
        selectedCatModel = categoryModels[row]
        categoryTF.text = categoryModels[row].catName ?? "Cat Name"
        
       
    }
    
    @objc func catPickerCancelClicked(){
        categoryTF.resignFirstResponder()
    }
    
    @objc func cashClicked(){
        cashCheck.isSelected = true
        appleCheck.isSelected = false
        creditCheck.isSelected = false
    }
    
    @objc func applePayClicked(){
        appleCheck.isSelected = true
        creditCheck.isSelected = false
        cashCheck.isSelected = false
    }
    
    @objc func creditDebitClicked(){
        appleCheck.isSelected = false
        creditCheck.isSelected = true
        cashCheck.isSelected = false
    }
    
    func createOpeningDatePicker() {
        if #available(iOS 13.4, *) {
            openingDatePicker.preferredDatePickerStyle = .wheels
        }

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(openingDateDoneBtnTapped))
        toolbar.setItems([done], animated: true)
        
        openingTime.inputAccessoryView = toolbar
        
        openingDatePicker.datePickerMode = .time
        openingTime.inputView = openingDatePicker
    }
    @objc func openingDateDoneBtnTapped() {
        view.endEditing(true)
        let selectedDate = openingDatePicker.date
        self.openingTime.text = convertDateIntoTimeForRecurringVoucher(selectedDate)
    }
    
    func createClosingDatePicker() {
        if #available(iOS 13.4, *) {
            closingDatePicker.preferredDatePickerStyle = .wheels
        }

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(closingDateDoneBtnTapped))
        toolbar.setItems([done], animated: true)
        
        closingTime.inputAccessoryView = toolbar
        
        closingDatePicker.datePickerMode = .time
        closingTime.inputView =  closingDatePicker
    }
    @objc func closingDateDoneBtnTapped() {
        view.endEditing(true)
        let selectedDate =  closingDatePicker.date
        self.closingTime.text = convertDateIntoTimeForRecurringVoucher(selectedDate)
    }
    
    @objc func backBtnClicked() {
        self.dismiss(animated: true)
    }
    
    @objc func locationCellClicked(myGesture : MyGesture){
        fAddressTable.isHidden = true
        view.endEditing(true)
    

        let place = places[myGesture.index]
        fAddress.text = place.name ?? ""
        
        self.isLocationSelected = true
     
    
        GooglePlacesManager.shared.resolveLocation(for: place) { result in
            switch result {
            case .success(let coordinates) :
                self.latitude = coordinates.latitude
                self.longitude = coordinates.longitude
             
                
                break
            case .failure(let error) :
                print(error)
                
            }
        }
    }
    public func updateTableViewHeight(){
        
        self.fTableViewHeight.constant = self.fAddressTable.contentSize.height
        self.fAddressTable.layoutIfNeeded()
    }
    
    @objc func textFieldDidChange(textField : UITextField){
        guard let query = textField.text, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            self.places.removeAll()
        
            self.fAddressTable.reloadData()
            return
        }
        
        
        GooglePlacesManager.shared.findPlaces(query: query ) { result in
            switch result {
            case .success(let places) :
                self.places = places
                print(self.places)
                self.fAddressTable.reloadData()
                break
            case .failure(let error) :
                print(error)
            }
        }
    }
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    @IBAction func addBtnClicked(_ sender: Any) {
        let sName = mName.text
        let sAbout = fAbout.text
        let sEmail = mail.text
        let sPassword = password.text
        let sPhoneNumber = phoneNumber.text
        let sOpeningTime = openingTime.text
        let sClosingTime = closingTime.text
        let sAmount = enterAmount.text
        
        
        if !isImageSelected {
            self.showToast(message: "Uplaod Business Image")
        }
        else if sName == "" {
            self.showToast(message: "Enter Business Name")
        }
        else if self.selectedCatModel == nil {
            self.showToast(message: "Select Category")
        }
        else if !isLocationSelected {
            self.showToast(message: "Enter Address")
        }
        else if sPhoneNumber == "" {
            self.showToast(message: "Enter Phone Number")
        }
        else if sOpeningTime == "" {
            self.showToast(message: "Enter Opening Time")
        }
        else if sClosingTime == "" {
            self.showToast(message: "Enter Closing TIme")
        }
        else if sAbout == "" {
            self.showToast(message: "Enter About")
        }
        else if sEmail == "" {
            self.showToast(message: "Enter Email Address")
        }
        else if sPassword == "" {
            self.showToast(message: "Enter Password")
        }
        else if sAmount == "" {
            self.showToast(message: "Enter Amount")
        }
        else if !appleCheck.isSelected && !creditCheck.isSelected && !cashCheck.isSelected {
            self.showToast(message: "Select Payment Method")
        }
        else {
           
            let b2bModel = B2BModel()
            
            b2bModel.googleBusinessLink = self.googleBusinessLink.text
            b2bModel.catId = self.selectedCatModel!.id
            b2bModel.catName = self.selectedCatModel!.catName
            b2bModel.aboutBusiness = sAbout
            b2bModel.address = self.fAddress.text
            b2bModel.createDate = Date()
            b2bModel.email = sEmail
            b2bModel.password = sPassword
            b2bModel.latitude = self.latitude
            b2bModel.longitude = self.longitude
            b2bModel.name = sName
            b2bModel.amount = Int(sAmount!)!
            b2bModel.openingTime = self.openingDatePicker.date
            b2bModel.closingTime = self.closingDatePicker.date
            b2bModel.phoneNumber = sPhoneNumber
            b2bModel.franchiseId = FranchiseModel.data!.uid
            let location = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
            let hash = GFUtils.geoHash(forLocation: location)
            b2bModel.geoHash = hash
            self.b2bModel = b2bModel
            
            if cashCheck.isSelected {
                self.createB2b(b2bModel: b2bModel)
            }
            else {
                ProgressHUDShow(text: "")
                self.createCustomerForStripe(name: sName ?? "Name", email: sEmail ?? "Email") { customer_id, error in
                    
                    if let customerId = customer_id {
                        self.createPaymentIntentForStripe(amount: String((Int(sAmount ?? "1")!) * 100), currency: "USD", customer: customerId, email: sEmail ?? "support@softment.in") { client_secret, secret in
                            DispatchQueue.main.async {
                                self.ProgressHUDHide()
                            }
                            if let client_secret = client_secret,
                                let secret = secret{
                              
                                self.clientSec = client_secret
                                
                                    DispatchQueue.main.async {
                                        if self.creditCheck.isSelected {
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
                                              self.createB2b(b2bModel: b2bModel)
                                             
                                         case .failed(let error):
                                              self.showMessage(title: "Payment Failed", message: error.localizedDescription)
                                          case .canceled:
                                              print("Payment Cancelled")
                                          }
                                       }
                                      }
                                        else {
                                            self.handleApplePay(amount: Int(sAmount ?? "1")!, delegate: self)
                                        }
                                }
                        
                            }
                            else {
                                self.showError("payment id not found.")
                            }

                        }
                       
                    }
                    else {
                        DispatchQueue.main.async {
                            self.ProgressHUDHide()
                        }
                        self.showError("Stripe customer id not found")
                    }
                }
                
               
                
                
            }
            
           
        
        }
    }
    
    func createB2b(b2bModel : B2BModel){
        
        //DELETE PIPELINE
        if let pipeLineModel = pipeLineModel {
            FirebaseStoreManager.db.collection("Franchises").document(pipeLineModel.franchiseId ?? "123").collection("Pipelines").document(pipeLineModel.id ?? "123").delete()
        }
        
        
        self.ProgressHUDShow(text: "")
        self.createAuthUser(name: b2bModel.name!, email: b2bModel.email!, password: b2bModel.password!, isAdmin: true) { uid, error in
            
            if let error = error {
                self.ProgressHUDHide()
                self.showError(error)
            }
            else {
                if let uid = uid {
                    b2bModel.uid = uid
                    b2bModel.expiryDate = self.addYearToDate(years: 1, currentDate: Date())
                    self.uploadImageOnFirebase(id: uid) { downloadURL in
                            b2bModel.image = downloadURL
                            self.addB2B(b2bModel: b2bModel) { error in
                                self.ProgressHUDHide()
                                if let error = error {
                                    self.showError(error)
                                }
                                else {
                                    self.performSegue(withIdentifier: "franchiseCopySeg", sender: b2bModel)
                                }
                            }
                        }
                    
                   
                }
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "franchiseCopySeg" {
            if let VC = segue.destination as? FranchiseCopyEmailPasswordViewController {
                if let b2bModel = sender as? B2BModel {
                    VC.b2bModel = b2bModel
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
extension FranchiseAddB2BViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate,CropViewControllerDelegate {
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
        
        let storage = FirebaseStoreManager.storage.reference().child("B2BImages").child(id).child("\(id).png")
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
extension FranchiseAddB2BViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if places.count > 0 {
            tableView.isHidden = false
        }
        else {
            tableView.isHidden = true
        }
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "placescell", for: indexPath) as? Google_Places_Cell {
            
            
            cell.name.text = places[indexPath.row].name ?? "Something Went Wrong"
            cell.mView.isUserInteractionEnabled = true
            
            let myGesture = MyGesture(target: self, action: #selector(locationCellClicked(myGesture:)))
            myGesture.index = indexPath.row
            cell.mView.addGestureRecognizer(myGesture)
            
            let totalRow = tableView.numberOfRows(inSection: indexPath.section)
            if(indexPath.row == totalRow - 1)
            {
                DispatchQueue.main.async {
                    self.updateTableViewHeight()
                }
            }
            return cell
        }
        
        return Google_Places_Cell()
    }
    
    
    
}
extension FranchiseAddB2BViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        view.endEditing(true)
        return true
    }
}

extension FranchiseAddB2BViewController : ApplePayContextDelegate {
    func applePayContext(_ context: StripeApplePay.STPApplePayContext, didCompleteWith status: StripeApplePay.STPApplePayContext.PaymentStatus, error: Error?) {
        switch status {
      case .success:
            self.createB2b(b2bModel: self.b2bModel!)
      
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
extension FranchiseAddB2BViewController : UIPickerViewDelegate, UIPickerViewDataSource {

func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
}

func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    
        return categoryModels.count
    
     
    

}

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        
        return categoryModels[row].catName ?? ""
        
        
        
    }
}

