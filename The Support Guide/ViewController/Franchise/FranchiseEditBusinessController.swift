//
//  FranchiseEditBusinessController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 26/05/23.
//

import UIKit
import CropViewController
import CoreLocation
import GeoFire
import PassKit

class FranchiseEditBusinessController : UIViewController {
    
    @IBOutlet weak var deleteB2BBtn: UIView!
    
    @IBOutlet weak var googleBusinessLink: UITextField!
    let catPicker = UIPickerView()
    @IBOutlet weak var categoryTF: UITextField!
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

    
    let openingDatePicker = UIDatePicker()
    let closingDatePicker = UIDatePicker()
    var b2bModel : B2BModel?
    
    var categoryModels = Array<CategoryModel>()
    var selectedCatModel : CategoryModel?
    override func viewDidLoad() {
        
        if let pipeLineModel = b2bModel {
            if let imagePath = pipeLineModel.image, !imagePath.isEmpty {
                
                self.image.isHidden = false
                imageView.isHidden = true
               
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
            password.text = pipeLineModel.password ?? ""
            
            categoryTF.text = pipeLineModel.catName ?? ""
            
            let catModel = CategoryModel()
            catModel.catName = pipeLineModel.catName
            catModel.id = pipeLineModel.catId
            selectedCatModel = catModel
            
            googleBusinessLink.text = pipeLineModel.googleBusinessLink ?? ""
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
     
        //DELETEB2B
        deleteB2BBtn.isUserInteractionEnabled = true
        deleteB2BBtn.layer.cornerRadius = 8
        deleteB2BBtn.dropShadow()
        deleteB2BBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteB2bClicked)))
        
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
    
    func deleteB2B(){
        self.ProgressHUDShow(text: "Deleting...")
        
        FirebaseStoreManager.db.collection("Businesses").document(b2bModel!.uid ?? "123").collection("Vouchers").getDocuments { snapshot, error in
            
            if let snapshot = snapshot, !snapshot.isEmpty {
                let batch = FirebaseStoreManager.db.batch()
                for qdr in snapshot.documents {
                    if let voucherModel = try? qdr.data(as: VoucherModel.self) {
                        batch.deleteDocument(FirebaseStoreManager.db.collection("Businesses").document(self.b2bModel!.uid ?? "123").collection("Vouchers").document(voucherModel.id ?? "123"))
                    }
                }
                batch.commit()
            }
            
        }
        
        FirebaseStoreManager.db.collection("Businesses").document(b2bModel!.uid ?? "123").collection("PageVisits").getDocuments { snapshot, error in
            
            if let snapshot = snapshot, !snapshot.isEmpty {
                let batch = FirebaseStoreManager.db.batch()
                for qdr in snapshot.documents {
                
                    batch.deleteDocument(FirebaseStoreManager.db.collection("Businesses").document(self.b2bModel!.uid ?? "123").collection("PageVisits").document(qdr.documentID))
                   
                }
                batch.commit()
            }
            
        }
    
        FirebaseStoreManager.db.collection("Businesses").document(b2bModel!.uid ?? "123").collection("GoogleReviews").getDocuments { snapshot, error in
            let batch = FirebaseStoreManager.db.batch()
            batch.deleteDocument(FirebaseStoreManager.db.collection("Businesses").document(self.b2bModel!.uid ?? "123"))
            batch.deleteDocument(FirebaseStoreManager.db.collection("Businesses").document(self.b2bModel!.uid ?? "123").collection("Owner").document(self.b2bModel!.uid ?? "123"))
     
            if let snapshot = snapshot, !snapshot.isEmpty {
         
                for qdr in snapshot.documents {
                  
                    batch.deleteDocument(FirebaseStoreManager.db.collection("Businesses").document(self.b2bModel!.uid ?? "123").collection("GoogleReviews").document(qdr.documentID))
                   
                }
               
            }
            batch.commit { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                }
                else {
                    self.showToast(message: "Deleted")
                    let seconds = 2.5
                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                        self.dismiss(animated: true)
                    }
                }
            }
        }
        
     
        
        
    }
    
    
    @objc func deleteB2bClicked(){
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this business?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            self.deleteB2B()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
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
  
        if sName == "" {
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
     

        else {
            ProgressHUDShow(text: "")
            
            self.b2bModel!.googleBusinessLink = self.googleBusinessLink.text
            self.b2bModel!.catId = self.selectedCatModel!.id
            self.b2bModel!.catName = self.selectedCatModel!.catName
            self.b2bModel!.aboutBusiness = sAbout
            self.b2bModel!.address = self.fAddress.text
            self.b2bModel!.createDate = Date()
            self.b2bModel!.email = sEmail
            self.b2bModel!.password = sPassword
            self.b2bModel!.latitude = self.latitude
            self.b2bModel!.longitude = self.longitude
            self.b2bModel!.name = sName
            self.b2bModel!.openingTime = self.openingDatePicker.date
            self.b2bModel!.closingTime = self.closingDatePicker.date
            self.b2bModel!.phoneNumber = sPhoneNumber
           
            let location = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
            let hash = GFUtils.geoHash(forLocation: location)
            self.b2bModel!.geoHash = hash
            
          
           
            self.updateAuthUser(uid : self.b2bModel!.uid!,name: self.b2bModel!.name!, email: self.b2bModel!.email!, password: self.b2bModel!.password!) { uid, error in
                
                if let error = error {
                    self.ProgressHUDHide()
                    self.showError(error)
                }
                else {
                 
                    if self.isImageSelected {
                        self.uploadImageOnFirebase(id: self.b2bModel!.uid!) { downloadURL in
                            self.b2bModel!.image = downloadURL
                            self.updateB2B(b2bModel: self.b2bModel!)
                        }
                    }
                    else {
                        self.updateB2B(b2bModel: self.b2bModel!)
                    }
                        
                       
                    
                }
            }
              
        }

    }
    func updateB2B(b2bModel : B2BModel){
        self.updateB2B(b2bModel: b2bModel) { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error)
            }
            else {
                self.showToast(message: "Business Edited")
                let seconds = 2.5
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                    self.dismiss(animated: true)
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
extension FranchiseEditBusinessController : UIImagePickerControllerDelegate, UINavigationControllerDelegate,CropViewControllerDelegate {
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
extension FranchiseEditBusinessController : UITableViewDelegate, UITableViewDataSource {
    
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
extension FranchiseEditBusinessController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        view.endEditing(true)
        return true
    }
}

extension FranchiseEditBusinessController : UIPickerViewDelegate, UIPickerViewDataSource {

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

