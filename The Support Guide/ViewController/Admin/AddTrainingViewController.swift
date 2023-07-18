//
//  AddTrainingViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 16/05/23.
//
import UIKit
import CropViewController
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import MobileCoreServices
import UniformTypeIdentifiers
import AVFoundation

class AddTrainingViewController : UIViewController {
    
    @IBOutlet weak var franchiseCheck: UIButton!
    @IBOutlet weak var businessCheck: UIButton!
    @IBOutlet weak var businessView: UIStackView!
    @IBOutlet weak var franchiseView: UIStackView!
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var addBtn: UIButton!
  
    @IBOutlet weak var uploadVideoLabel: UILabel!
    
    @IBOutlet weak var uploadVideoView: UIView!
    
    var isImageSelected = false
    var videoPath : URL?
    var type : String = ""
    @IBOutlet weak var backBtn: UIView!
    
    
    override func viewDidLoad() {
        
        
        backBtn.isUserInteractionEnabled = true
        backBtn.dropShadow()
        backBtn.layer.cornerRadius = 8
        backBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        addBtn.layer.cornerRadius = 12
        
        uploadVideoView.isUserInteractionEnabled = true
        uploadVideoView.layer.borderWidth = 1
        uploadVideoView.addBorderView()
        uploadVideoView.layer.cornerRadius = 8
        uploadVideoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addMusicClicked)))
        
        name.delegate = self

        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = 12
        imageView.addBorderView()
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewClicked)))
        
        image.isUserInteractionEnabled = true
        image.layer.cornerRadius = 12
        image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewClicked)))
    
        businessView.isUserInteractionEnabled = true
        businessView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(businessClicked)))
        
        franchiseView.isUserInteractionEnabled = true
        franchiseView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(franchiseClicked)))
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
    }
    
    @objc func businessClicked(){
        type = "b2b"
        businessCheck.isSelected = true
        franchiseCheck.isSelected = false
    }
    
    @objc func franchiseClicked(){
        type = "franchise"
        businessCheck.isSelected = false
        franchiseCheck.isSelected = true
    }
    
    @objc func backBtnClicked() {
        self.dismiss(animated: true)
    }
    
    
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @objc func addMusicClicked(){
        

        let image = UIImagePickerController()
        image.delegate = self
        image.title = title
        image.mediaTypes = ["public.movie"]
        image.sourceType = .photoLibrary
        self.present(image,animated: true)
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
    
  
    
    @IBAction func addBtnClicked(_ sender: Any) {
        
        Task { @MainActor in
            
            let sTitle = self.name.text?.trimmingCharacters(in: .whitespacesAndNewlines)
           
            if type == "" {
                self.showToast(message: "Select Type")
            }
            else if !isImageSelected {
                self.showToast(message: "Upload Image")
            }
            else if self.videoPath == nil {
                self.showToast(message: "Upload Video")
            }
            else if sTitle!.isEmpty {
                self.showToast(message: "Enter Title")
            }
            
            else {
              
                let musicId = Firestore.firestore().collection("Trainings").document().documentID
                let musicModel = TrainingModel()
                
                musicModel.type = self.type
                musicModel.id = musicId
                musicModel.duration = await Int(self.getVideoDuration())
                musicModel.title = sTitle ?? ""
                musicModel.createdDate = Date()
                self.ProgressHUDShow(text: "Uploading Video")
                self.uploadMusicOnFirebase(musicId: musicId) { downloadURL in
                    self.ProgressHUDHide()
                    if !downloadURL.isEmpty {
                        musicModel.videoUrl = downloadURL
                        self.ProgressHUDShow(text: "")
                        self.uploadImageOnFirebase(musicId: musicId) { downloadURL in
                            self.ProgressHUDHide()
                            if !downloadURL.isEmpty {
                                musicModel.thumbnail = downloadURL
                                self.uploadMusicModelOnFirebase(musicModel: musicModel)
                                
                            }
                            
                            
                        }
                    }
                }
            
            }
        }
    }
    
    
}

extension AddTrainingViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate,CropViewControllerDelegate {
    
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
        else {
            
            self.dismiss(animated: true) {
                self.videoPath = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.mediaURL.rawValue)] as? URL
                self.uploadVideoLabel.text  = "Video Uploaded"
                self.uploadVideoView.layer.backgroundColor = UIColor(red: 152/255, green: 198/255, blue: 106/255, alpha: 1).cgColor
            }
          
         
        }
        
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        
        isImageSelected = true
        self.image.image = image
        self.image.isHidden = false
        imageView.isHidden = true
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func uploadImageOnFirebase(musicId : String,completion : @escaping (String) -> Void ) {
        var downloadUrl = ""
        
        
        let storage = Storage.storage().reference().child("TrainingsImages").child(musicId).child("\(musicId).png")
        
        
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
    
    func getVideoDuration() async -> Double{
        let avplayeritem = AVPlayerItem(url: videoPath! as URL)
        
        let totalSeconds = try? await avplayeritem.asset.load(.duration).seconds
        return totalSeconds ?? 0
    }
    
    func uploadMusicModelOnFirebase(musicModel : TrainingModel){
        ProgressHUDShow(text: "")
        try? Firestore.firestore().collection("Trainings").document(musicModel.id ?? "123").setData(from: musicModel) { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                self.showToast(message: "Training Added")
                let seconds = 2.5
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                    self.dismiss(animated: true)
                }
                   
               
                
            }
        }
    }
    func uploadMusicOnFirebase(musicId : String,completion : @escaping (String) -> Void ) {
        var downloadUrl = ""
        
        
        let storage = Storage.storage().reference().child("Trainings").child(musicId).child("\(musicId).mp4")
        
        
        let metadata = StorageMetadata()
        //specify MIME type
        
        metadata.contentType = "video/mp4"
        
        if let musicData = try? NSData(contentsOf: videoPath!, options: .mappedIfSafe) as Data {
            
            storage.putData(musicData, metadata: metadata) { metadata, error in
                
                if error == nil {
                    storage.downloadURL { (url, error) in
                        if error == nil {
                            downloadUrl = url!.absoluteString
                        }
                        completion(downloadUrl)
                        
                    }
                }
                else {
                    print(error!.localizedDescription)
                    completion(downloadUrl)
                }
            }
        }
        else {
            completion(downloadUrl)
            self.showToast(message: "ERROR")
        }
    }
}

extension AddTrainingViewController : UITextFieldDelegate, UITextViewDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}

