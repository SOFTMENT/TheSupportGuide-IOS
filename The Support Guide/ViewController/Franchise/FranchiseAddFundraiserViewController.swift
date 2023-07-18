//
//  FranchiseAddFundraiserViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 21/05/23.
//


import UIKit
import CropViewController
import CoreLocation
import GeoFire

class FranchiseAddFundraiserViewController : UIViewController {

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
   
    var pipeLineModel : PipelineModel?

    override func viewDidLoad() {
        
        if let pipeLineModel = pipeLineModel {
            if let imagePath = pipeLineModel.image, !imagePath.isEmpty {
                isImageSelected = true
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
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
      
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
        
       
        if !isImageSelected {
            self.showToast(message: "Uplaod Fundraiser Image")
        }
        else if sName == "" {
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
            let fundraiserModel = FundraiserModel()
            
            fundraiserModel.aboutBusiness = sAbout
            fundraiserModel.address = self.fAddress.text
            fundraiserModel.createDate = Date()
            fundraiserModel.email = sEmail
            fundraiserModel.password = sPassword
            fundraiserModel.latitude = self.latitude
            fundraiserModel.longitude = self.longitude
            fundraiserModel.name = sName
            fundraiserModel.phoneNumber = sPhoneNumber
            fundraiserModel.franchiseId = FranchiseModel.data!.uid
            let location = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
            let hash = GFUtils.geoHash(forLocation: location)
            fundraiserModel.geoHash = hash
        
            self.ProgressHUDShow(text: "")
            self.createAuthUser(name: fundraiserModel.name!, email: fundraiserModel.email!, password: fundraiserModel.password!, isAdmin: true) { uid, error in
                
                if let error = error {
                    self.ProgressHUDHide()
                    self.showError(error)
                }
                else {
                    //DELETE PIPELINE
                    if let pipeLineModel = self.pipeLineModel {
                        FirebaseStoreManager.db.collection("Franchises").document(pipeLineModel.franchiseId ?? "123").collection("Pipelines").document(pipeLineModel.id ?? "123").delete()
                    }
                    
                    if let uid = uid {
                        fundraiserModel.uid = uid
                        self.uploadImageOnFirebase(id: uid) { downloadURL in
                                fundraiserModel.image = downloadURL
                       
                            self.addFundraiser(fundRaiserModel: fundraiserModel) { error in
                                self.ProgressHUDHide()
                                if let error = error {
                                    self.showError(error)
                                }
                                else {
                                    self.performSegue(withIdentifier: "franchiseCopyFundraiserSeg", sender: fundraiserModel)
                                }
                            }
                            }
                        
                       
                    }
                }
            }
            
            
           
        
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "franchiseCopyFundraiserSeg" {
            if let VC = segue.destination as? FranchiseCopyFundraiserIdPasswordViewControlelr {
                if let fundraiseModel = sender as? FundraiserModel {
                    VC.fundraiserModel = fundraiseModel
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
extension FranchiseAddFundraiserViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate,CropViewControllerDelegate {
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
extension FranchiseAddFundraiserViewController : UITableViewDelegate, UITableViewDataSource {
    
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
extension FranchiseAddFundraiserViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        view.endEditing(true)
        return true
    }
}

