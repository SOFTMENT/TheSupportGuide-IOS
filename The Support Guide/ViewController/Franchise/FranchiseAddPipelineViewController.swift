//
//  FranchiseAddPipelineViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 21/05/23.
//


import UIKit
import CropViewController
import CoreLocation
import GeoFire

class FranchiseAddPipelineViewController : UIViewController {

    let levelPicker = UIPickerView()
    @IBOutlet weak var intrestLevel: UITextField!
    var franchiseType : FranchiseType?
    @IBOutlet weak var businessView: UIStackView!
    @IBOutlet weak var fundraiserView: UIStackView!
    @IBOutlet weak var fundraiserCheck: UIButton!
    @IBOutlet weak var businessCheck: UIButton!
    @IBOutlet weak var backBtn: UIView!
    @IBOutlet weak var imageStackView: UIStackView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var mName: UITextField!
    @IBOutlet weak var mail: UITextField!

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
    var intrestLevelNumber = -1

    override func viewDidLoad() {
        
        businessView.isUserInteractionEnabled = true
        fundraiserView.isUserInteractionEnabled = true
        
        businessView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(businessClicked)))
        fundraiserView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(fundraiserClicked)))
        
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
       
        intrestLevel.delegate = self
        levelPicker.delegate = self
        levelPicker.dataSource = self
        intrestLevel.setRightIcons(icon: UIImage(named: "down-arrow")!)
        intrestLevel.rightView?.isUserInteractionEnabled = true
        
        // ToolBar
        let levelBar = UIToolbar()
        levelBar.barStyle = .default
        levelBar.isTranslucent = true
        levelBar.tintColor = .link
        levelBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton1 = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(levelPickerDoneClicked))
        let spaceButton1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton1 = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(levelPickerCancelClicked))
        levelBar.setItems([cancelButton1, spaceButton1, doneButton1], animated: false)
        levelBar.isUserInteractionEnabled = true
        intrestLevel.inputAccessoryView = levelBar
        intrestLevel.inputView = levelPicker
        
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
      
        createOpeningDatePicker()
        createClosingDatePicker()
    }
    @objc func levelPickerDoneClicked(){
        
        
        intrestLevel.resignFirstResponder()
        let row = levelPicker.selectedRow(inComponent: 0)
        intrestLevelNumber = row + 1
        intrestLevel.text = Constants.INTREST_LEVEL[row]
        
       
    }
    
    @objc func levelPickerCancelClicked(){
       intrestLevel.resignFirstResponder()
    }
    @objc func businessClicked(){
        franchiseType = .B2B
        businessCheck.isSelected = true
        fundraiserCheck.isSelected = false
        
        openingTime.isHidden = false
        closingTime.isHidden = false
    }
    
    @objc func fundraiserClicked(){
        franchiseType = .FUNDRAISER
        businessCheck.isSelected = false
        fundraiserCheck.isSelected = true
        
        openingTime.isHidden = true
        closingTime.isHidden = true
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
      
        let sPhoneNumber = phoneNumber.text
        let sOpeningTime = openingTime.text
        let sClosingTime = closingTime.text
       
        if !businessCheck.isSelected && !fundraiserCheck.isSelected {
            self.showToast(message: "Select Account Type")
        }
        else if !isImageSelected {
            self.showToast(message: "Uplaod Image")
        }
        else if sName == "" {
            self.showToast(message: "Enter Name")
        }
        else if !isLocationSelected {
            self.showToast(message: "Enter Address")
        }
        else if sPhoneNumber == "" {
            self.showToast(message: "Enter Phone Number")
        }
        else if sOpeningTime == "" && businessCheck.isSelected {
            self.showToast(message: "Enter Opening Time")
        }
        else if sClosingTime == "" && businessCheck.isSelected{
            self.showToast(message: "Enter Closing TIme")
        }
        else if sAbout == "" {
            self.showToast(message: "Enter About")
        }
        else if sEmail == "" {
            self.showToast(message: "Enter Email Address")
        }
        else if self.intrestLevelNumber == -1 {
            self.showToast(message: "Select Intrest Level")
        }
        else {
           
            let pipelineModel = PipelineModel()
            
            if self.franchiseType == .B2B {
                pipelineModel.type = "b2b"
            }
            else if self.franchiseType == .FUNDRAISER {
                pipelineModel.type = "sales"
            }
            pipelineModel.aboutBusiness = sAbout
            pipelineModel.address = self.fAddress.text
            pipelineModel.createDate = Date()
            pipelineModel.email = sEmail
         
            pipelineModel.latitude = self.latitude
            pipelineModel.longitude = self.longitude
            pipelineModel.name = sName
            pipelineModel.openingTime = self.openingDatePicker.date
            pipelineModel.closingTime = self.closingDatePicker.date
            pipelineModel.phoneNumber = sPhoneNumber
            pipelineModel.franchiseId = FranchiseModel.data!.uid
            pipelineModel.level = self.intrestLevelNumber
            let location = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
            let hash = GFUtils.geoHash(forLocation: location)
            pipelineModel.geoHash = hash
        
            self.ProgressHUDShow(text: "")
            let id = FirebaseStoreManager.db.collection("Franchises").document(pipelineModel.franchiseId ?? "123").collection("Pipelines").document().documentID
                pipelineModel.id = id
                self.uploadImageOnFirebase(id: id) { downloadURL in
                    pipelineModel.image = downloadURL
                
                    try? FirebaseStoreManager.db.collection("Franchises").document(pipelineModel.franchiseId ?? "123").collection("Pipelines").document(id).setData(from: pipelineModel,completion: { error in
                        self.ProgressHUDHide()
                        if let error = error {
                            self.showError(error.localizedDescription)
                        }
                        else {
                            self.showToast(message: "Pipeline Added")
                            let seconds = 2.5
                            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                self.dismiss(animated: true)
                            }
                        }
                    })
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
extension FranchiseAddPipelineViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate,CropViewControllerDelegate {
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
        
        let storage = FirebaseStoreManager.storage.reference().child("PipelineImages").child(id).child("\(id).png")
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
extension FranchiseAddPipelineViewController : UITableViewDelegate, UITableViewDataSource {
    
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
extension FranchiseAddPipelineViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        view.endEditing(true)
        return true
    }
}
extension FranchiseAddPipelineViewController : UIPickerViewDelegate, UIPickerViewDataSource {

func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
}

func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    
        return Constants.INTREST_LEVEL.count
    
     
    

}

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        
        return Constants.INTREST_LEVEL[row]
        
        
        
    }
}

