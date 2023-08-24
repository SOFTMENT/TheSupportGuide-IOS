//
//  FranchiseEditFundraiserViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 26/05/23.
//


import UIKit
import CropViewController
import CoreLocation
import GeoFire
import Firebase
import FirebaseFirestoreSwift

class FranchiseEditFundraiserViewController : UIViewController {

    @IBOutlet weak var deleteBtn: UIView!
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
   
    var fundraiserModel : FundraiserModel?

    override func viewDidLoad() {
        
        if let pipeLineModel = fundraiserModel {
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
    
            fAbout.text = pipeLineModel.aboutBusiness ?? ""
            mail.text = pipeLineModel.email ?? ""
            password.text = pipeLineModel.password ?? ""
            
            
        }
        
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
        
        deleteBtn.isUserInteractionEnabled = true
        deleteBtn.dropShadow()
        deleteBtn.layer.cornerRadius = 8
        deleteBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteFundrasierClicked)))
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
      
    }
    
    func deleteFundraiser(){
        self.ProgressHUDShow(text: "Deleting...")
        
        lazy var functions = Functions.functions()
        
        functions.httpsCallable("deleteUser").call([fundraiserModel!.uid ?? "123"]) { result, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        FirebaseStoreManager.db.collection("Fundraisers").document(fundraiserModel!.uid ?? "123").collection("Goals").getDocuments { snapshot, error in
            
            if let snapshot = snapshot, !snapshot.isEmpty {
                let batch = FirebaseStoreManager.db.batch()
                for qdr in snapshot.documents {
                    if let goalModel = try? qdr.data(as: GoalModel.self) {
                        batch.deleteDocument(  FirebaseStoreManager.db.collection("Fundraisers").document(self.fundraiserModel!.uid ?? "123").collection("Goals").document(goalModel.id ?? "123"))
                    }
                }
                batch.commit()
            }
            
        }
        
        
    
        FirebaseStoreManager.db.collection("Fundraisers").document(fundraiserModel!.uid ?? "123").collection("Members").getDocuments { snapshot, error in
            let batch = FirebaseStoreManager.db.batch()
            batch.deleteDocument(FirebaseStoreManager.db.collection("Fundraisers").document(self.fundraiserModel!.uid ?? "123"))
            batch.deleteDocument(FirebaseStoreManager.db.collection("Franchises").document(FranchiseModel.data!.uid ?? "123").collection("Recents").document(self.fundraiserModel!.uid ?? "123"))
     
            if let snapshot = snapshot, !snapshot.isEmpty {
         
                for qdr in snapshot.documents {
                    if let memberModel = try? qdr.data(as: SalesMemberModel.self) {
                        batch.deleteDocument(  FirebaseStoreManager.db.collection("Fundraisers").document(self.fundraiserModel!.uid ?? "123").collection("Members").document(memberModel.id ?? "123"))
                    }
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
    
    @objc func deleteFundrasierClicked(){
        
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this fundraiser?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            self.deleteFundraiser()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
        
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
        
       
        if sName == "" {
            self.showToast(message: "Enter Fundraiser Name")
        }
        else if !isLocationSelected {
            self.showToast(message: "Enter Address")
        }
        else if sPhoneNumber == "" {
            self.showToast(message: "Enter Phone Number")
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
           
            
            self.fundraiserModel!.aboutBusiness = sAbout
            self.fundraiserModel!.address = self.fAddress.text
            self.fundraiserModel!.createDate = Date()
            self.fundraiserModel!.email = sEmail
            self.fundraiserModel!.password = sPassword
            self.fundraiserModel!.latitude = self.latitude
            self.fundraiserModel!.longitude = self.longitude
            self.fundraiserModel!.name = sName
            self.fundraiserModel!.phoneNumber = sPhoneNumber
          
            let location = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
            let hash = GFUtils.geoHash(forLocation: location)
            self.fundraiserModel!.geoHash = hash
           
            self.updateAuthUser(uid : self.fundraiserModel!.uid!,name: self.fundraiserModel!.name!, email: self.fundraiserModel!.email!, password: self.fundraiserModel!.password!) { uid, error in
                
                if let error = error {
                    self.ProgressHUDHide()
                    self.showError(error)
                }
                else {
                 
                    if self.isImageSelected {
                        self.uploadImageOnFirebase(id:self.fundraiserModel!.uid!) { downloadURL in
                            self.fundraiserModel!.image = downloadURL
                            self.updateFundraiser(fundraiserModel: self.fundraiserModel!)
                        }
                    }
                    else {
                        self.updateFundraiser(fundraiserModel: self.fundraiserModel!)
                    }
                        
               
                }
            }
            
            
           
        
        }
    }
    func updateFundraiser(fundraiserModel : FundraiserModel){
        
        self.updateFundraiser(fundraiserModel: fundraiserModel) { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error)
            }
            else {
                self.showToast(message: "Fundraiser Edited")
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
extension FranchiseEditFundraiserViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate,CropViewControllerDelegate {
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
        
        let storage = FirebaseStoreManager.storage.reference().child("FundraiserImages").child(id).child("\(id).png")
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
extension FranchiseEditFundraiserViewController : UITableViewDelegate, UITableViewDataSource {
    
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
extension FranchiseEditFundraiserViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        view.endEditing(true)
        return true
    }
}

