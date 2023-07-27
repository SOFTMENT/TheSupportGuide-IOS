//
//  UserBusinessDetailsViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 11/06/23.
//


import UIKit
import MapKit

class UserBusinessDetailsViewController : UIViewController {
    @IBOutlet weak var locationStack: UIStackView!
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noVouchersAvailable: UILabel!
    
    @IBOutlet weak var leaveReviewBtn: UIButton!
    @IBOutlet weak var aboutOwnerBtn: UIButton!
    @IBOutlet weak var viewAllLocationsBtn: UIButton!
    @IBOutlet weak var titleHead: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var mProfile: UIImageView!
    @IBOutlet weak var businessName: UILabel!
   
    @IBOutlet weak var businessPhone: UILabel!
    @IBOutlet weak var businessLocation: UILabel!
    @IBOutlet weak var openingTime: UILabel!
    @IBOutlet weak var closingTime: UILabel!
    @IBOutlet weak var aboutBusiness: UILabel!
    var b2bModel : B2BModel?
    var voucherModels = Array<VoucherModel>()
    @IBOutlet weak var favBtn: UIView!
    @IBOutlet weak var favImage: UIImageView!
    
    
    override func viewDidLoad() {
        
        guard let b2bModel = b2bModel else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        titleHead.text = b2bModel.name ?? ""
        
        viewAllLocationsBtn.layer.cornerRadius = 6
        
        if let hasOwnerProfile = b2bModel.hasOwnerProfile, hasOwnerProfile {
            aboutOwnerBtn.layer.cornerRadius = 6
            aboutOwnerBtn.isHidden = false
        }
        else {
            aboutOwnerBtn.isHidden = true
        }
        
        leaveReviewBtn.layer.cornerRadius = 6
        
        if b2bModel.googleBusinessLink == nil || b2bModel.googleBusinessLink == "" {
            leaveReviewBtn.isHidden = true
        }
        
        businessName.text = b2bModel.name ?? ""
      
        businessPhone.text = b2bModel.phoneNumber ?? ""
        businessLocation.text = b2bModel.address ?? ""
        
        openingTime.text = self.convertDateIntoTimeForRecurringVoucher(b2bModel.openingTime ?? Date())
        closingTime.text = self.convertDateIntoTimeForRecurringVoucher(b2bModel.closingTime ?? Date())
        
        aboutBusiness.text = b2bModel.aboutBusiness ?? ""
        
        mProfile.layer.cornerRadius = 8
        if let path = b2bModel.image,!path.isEmpty {
            mProfile.sd_setImage(with: URL(string: path), placeholderImage: UIImage(named: "profile-placeholder"))
        }
      
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        tableView.delegate = self
        tableView.dataSource = self
        
        ProgressHUDShow(text: "")
        getAllVouchers(by: b2bModel.uid ?? "123") { voucherModels, error in
            self.ProgressHUDHide()
            if let voucherModels = voucherModels {
                self.voucherModels.removeAll()
                self.voucherModels.append(contentsOf: voucherModels)
                self.tableView.reloadData()
            }
        }
        
        locationStack.isUserInteractionEnabled = true
        locationStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(locationStackClicked)))
       
        
        favBtn.layer.cornerRadius = 8
        favBtn.dropShadow()
        favBtn.isUserInteractionEnabled = true
        favBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(favBtnClicked)))
        
        updateBusinessPageClicked()
        
        businessPhone.isUserInteractionEnabled = true
        businessPhone.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(phoneNumberClicked)))
      
        if !FirebaseStoreManager.auth.currentUser!.isAnonymous {
            checkLike(b2bId: b2bModel.uid ?? "123", completion: { isLike in
                if isLike {
                    self.favImage.image = UIImage(systemName: "heart.fill")
                    self.favImage.tintColor = .red
                }
                else {
                    self.favImage.image = UIImage(systemName: "heart")
                    self.favImage.tintColor = .black
                }
            })
        }
    }
    private func callNumber(phoneNumber: String) {
        guard let url = URL(string: "telprompt://\(phoneNumber)"),
            UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    @objc func phoneNumberClicked(){
        callNumber(phoneNumber: businessPhone.text ?? "")
    }
    
    @objc func favBtnClicked(){
        if FirebaseStoreManager.auth.currentUser!.isAnonymous {
            self.beRootScreen(mIdentifier: Constants.StroyBoard.signInViewController)
        }
        else {
            ProgressHUDShow(text: "")
            
            checkLike(b2bId: b2bModel!.uid ?? "123", completion: { isLike in
                self.ProgressHUDHide()
                if isLike {
                    self.removeLike(b2bId: self.b2bModel!.uid ?? "123")
                    self.favImage.image = UIImage(systemName: "heart")
                    self.favImage.tintColor = .black
                }
                else {
                    self.addLike(b2bId: self.b2bModel!.uid ?? "123")
                    self.favImage.image = UIImage(systemName: "heart.fill")
                    self.favImage.tintColor = .red
                }
            })
        }
       

    }
    
    func updateBusinessPageClicked(){
        let googleReviewModel = GoogleReviewModel()
        googleReviewModel.date = Date()
        googleReviewModel.userId = FirebaseStoreManager.auth.currentUser!.uid
        googleReviewModel.businessId = b2bModel!.uid
        let id = FirebaseStoreManager.db.collection("Businesses").document(b2bModel!.uid ?? "123").collection("PageVisits").document().documentID
        try? FirebaseStoreManager.db.collection("Businesses").document(b2bModel!.uid ?? "123").collection("PageVisits").document(id).setData(from: googleReviewModel)
    }
    
    @objc func locationStackClicked(){
        self.openInMapsClicked()
    }
    
    @IBAction func viewAllLocationsClicked(_ sender: Any) {
        performSegue(withIdentifier: "viewAllStoresSeg", sender: nil)
    }
    
    @IBAction func aboutOwnerClicked(_ sender: Any) {
        performSegue(withIdentifier: "viewOwnerProfileSeg", sender: nil)
    }
    
    @IBAction func leaveReviewClicked(_ sender: Any) {
        
        self.updateGoogleReviewClick()
        
        guard let url = URL(string: b2bModel!.googleBusinessLink ?? "") else { return}
        UIApplication.shared.open(url)
      
    }
  
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewOwnerProfileSeg" {
            if let VC = segue.destination as? ViewOwnerProfileViewController {
                VC.b2bId = self.b2bModel!.uid
            }
        }
        else if segue.identifier == "viewAllStoresSeg" {
            if let VC = segue.destination as? UserBusinessAllLocationViewController {
                VC.b2bId = self.b2bModel!.uid
            }
        }
        else if segue.identifier == "viewVoucherSeg" {
            if let VC = segue.destination as? UserViewVoucherController {
                if let voucherModel = sender as? VoucherModel {
                    VC.voucherModel = voucherModel
                    VC.businessModel = self.b2bModel
                }
            }
        }
    }
    
    @objc func openInMapsClicked(){
        showOpenMapPopup(latitude: b2bModel!.latitude ?? 0.0, longitude: b2bModel!.longitude ?? 0.0)
    }
    
  
    func showOpenMapPopup(latitude : Double, longitude : Double){
        let alert = UIAlertController(title: nil, message: "Open in maps", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Apple Maps", style: .default, handler: { action in
           
            let coordinate = CLLocationCoordinate2DMake(latitude,longitude)
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
            mapItem.name = self.b2bModel?.name ?? ""
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        }))
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
        
            alert.addAction(UIAlertAction(title: "Google Maps", style: .default, handler: { action in
                
                UIApplication.shared.open(URL(string:"comgooglemaps://?center=\(latitude),\(longitude)&zoom=14&views=traffic&q=\(latitude),\(longitude)")!, options: [:], completionHandler: nil)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true, completion: nil)
    }
    
    func updateGoogleReviewClick(){
        let googleReviewModel = GoogleReviewModel()
        googleReviewModel.date = Date()
        googleReviewModel.userId = FirebaseStoreManager.auth.currentUser!.uid
        googleReviewModel.businessId = b2bModel!.uid
        let id = FirebaseStoreManager.db.collection("Businesses").document(b2bModel!.uid ?? "123").collection("GoogleReviews").document().documentID
        try? FirebaseStoreManager.db.collection("Businesses").document(b2bModel!.uid ?? "123").collection("GoogleReviews").document(id).setData(from: googleReviewModel)
    }
    @objc func cellClicked(gest : MyGesture){
        performSegue(withIdentifier: "viewVoucherSeg", sender: voucherModels[gest.index])
    }
    
    func updateTableViewHeight(){
        self.tableViewHeight.constant = self.tableView.contentSize.height
        self.tableView.layoutIfNeeded()
    }
}

extension UserBusinessDetailsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.noVouchersAvailable.isHidden = voucherModels.count > 0 ? true : false
        return voucherModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "voucherCell", for: indexPath) as? VoucherTableViewCell {
            
            let voucherModel = voucherModels[indexPath.row]
           
            cell.mView.layer.cornerRadius = 8
            cell.mTitle.text = voucherModel.title ?? ""
            cell.mConditions.text = voucherModel.conditions ?? ""
            if let isFree = voucherModel.isFree, isFree {
                cell.freeLabel.text = "FREE"
            }
            else {
                cell.freeLabel.text = "OFF"
            }
            cell.mProfile.layer.cornerRadius = 4
            
            if let path = voucherModel.mImage, !path.isEmpty {
                cell.mProfile.sd_setImage(with: URL(string: path), placeholderImage: UIImage(named: "placeholder"))
            }
            
            
            cell.freeView.layer.cornerRadius = 4
            
            cell.mView.isUserInteractionEnabled = true
            let gest = MyGesture(target: self, action: #selector(cellClicked(gest: )))
            gest.index = indexPath.row
            cell.addGestureRecognizer(gest)
            
            DispatchQueue.main.async {
                self.updateTableViewHeight()
            }
            
            return cell
        }
        return VoucherTableViewCell()
    }
    
    
    
    
    
    
}
