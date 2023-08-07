//
//  HomeViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 28/04/23.
//

import UIKit
import SDWebImage
import CoreLocation
import Firebase
import GeoFire
class HomeViewController : UIViewController {
    
    
    @IBOutlet weak var no_businesses_available: UILabel!
    @IBOutlet weak var welcomeUsername: UILabel!
    @IBOutlet weak var searchBtn: UIView!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var commingOffersCat: UIView!
    @IBOutlet weak var shoppingCat: UIView!
    @IBOutlet weak var restaurantsCat: UIView!
    @IBOutlet weak var sportsCat: UIView!
    @IBOutlet weak var entertainmentCat: UIView!
    @IBOutlet weak var othersCat: UIView!
    @IBOutlet weak var seeAllCat: UILabel!
    @IBOutlet weak var tableView: UITableView!
    let currentUser = FirebaseStoreManager.auth.currentUser
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    var locationManager : CLLocationManager!
    let radiusInM: Double = 2000 * 1000
    var b2bModels = Array<B2BModel>()
    var i = 0
    override func viewDidLoad() {
        
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        FirebaseStoreManager.db.collection("VERSION").document(FirebaseStoreManager.auth.currentUser!.uid).setData(["date": Data(),"VERSION": appVersion ?? "123"],merge: true)
        
        guard let currentUser = currentUser else {
            DispatchQueue.main.async {
                self.logout()
            }
            return
        }
       
        if currentUser.isAnonymous {
            welcomeUsername.text = "Welcome"
        }
        else {
            if let userModel = UserModel.data {
                welcomeUsername.text = "Welcome, \(userModel.fullName ?? "")"
                
                if let profilePath = userModel.profilePic, !profilePath.isEmpty {
                    profilePic.sd_setImage(with: URL(string: profilePath), placeholderImage: UIImage(named: "profile-placeholder"),options: .continueInBackground)
                    
                }
            }
           
        }
        
        searchBtn.layer.cornerRadius = 8
        
        searchTF.delegate = self
        
        profilePic.makeRounded()
        
        addBorderAndCorner(view: commingOffersCat)
        commingOffersCat.isUserInteractionEnabled = true
        commingOffersCat.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(newOfferClicked)))
        
        addBorderAndCorner(view: shoppingCat)
        shoppingCat.isUserInteractionEnabled = true
        shoppingCat.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(shoppingClicked)))
        
        addBorderAndCorner(view: restaurantsCat)
        restaurantsCat.isUserInteractionEnabled = true
        restaurantsCat.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(restaurantsClicked)))
        
        addBorderAndCorner(view: sportsCat)
        sportsCat.isUserInteractionEnabled = true
        sportsCat.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sportsAndFitnessClicked)))
        
        addBorderAndCorner(view: entertainmentCat)
        entertainmentCat.isUserInteractionEnabled = true
        entertainmentCat.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(entertainmentClicked)))
        
        addBorderAndCorner(view: othersCat)
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        othersCat.isUserInteractionEnabled = true
        othersCat.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showAllCategories)))
        
        seeAllCat.isUserInteractionEnabled = true
        seeAllCat.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showAllCategories)))
     
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        ProgressHUDShow(text: "")
        let authorizationStatus: CLAuthorizationStatus

        if #available(iOS 14, *) {
            authorizationStatus = locationManager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }

        
        switch authorizationStatus {
        case .authorizedWhenInUse,.authorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            self.showToast(message: "Enable Location From Settings")
            FirebaseStoreManager.db.collection("ERRORS").document(FirebaseStoreManager.auth.currentUser!.uid).setData(["date":Data(),"error":"LocationNotAuthorized"],merge: true)
        }
    }
    
    func getAllBusinessByLocation(){
        
        
        let center = CLLocationCoordinate2D(latitude: Constants.clLocation.coordinate.latitude, longitude: Constants.clLocation.coordinate.longitude)
        
        
        let queryBounds = GFUtils.queryBounds(forLocation: center,
                                              withRadius: radiusInM)
        
        
        var queries : [Firebase.Query]!
        
        
        
        queries = queryBounds.map { bound -> Firebase.Query in
            
            return Firestore.firestore().collection("Businesses")
                .order(by: "geoHash")
                .start(at: [bound.startValue])
                .end(at: [bound.endValue])
        }
        
        
        
        B2BModel.b2bModels.removeAll()
 
        
        for query in queries {
         
            query.getDocuments(completion: getDocumentsCompletion)
        }
        
        self.ProgressHUDHide()
    }
    
    func getDocumentsCompletion(snapshot: QuerySnapshot?, error: Error?) -> () {
        
        guard let documents = snapshot?.documents else {
            self.showError(error!.localizedDescription)
            return
        }
        
        
        for document in documents {
 
            // We have to filter out a few false positives due to GeoHash accuracy, but
            // most will match
       
                if let b2bModel = try? document.data(as: B2BModel.self) {
                 
                    B2BModel.b2bModels.removeAll { b2b in
                        if b2bModel.uid == b2b.uid {
                            return true
                        }
                        return false
                    }
                    
                    B2BModel.b2bModels.append(b2bModel)
                
            }
        }
        
        B2BModel.b2bModels =  B2BModel.b2bModels.filter { b2bModel in
            if (b2bModel.expiryDate ?? Date()) > Date() {
                return true
            }
            else {
                 return false
            }
        }
        
        B2BModel.b2bModels.sort { b2b1, b2b2 in
            
            let coordinate1 = CLLocation(latitude: b2b1.latitude ?? 0.0, longitude: b2b1.longitude ?? 0.0)
            let coordinate2 = CLLocation(latitude: Constants.clLocation.coordinate.latitude, longitude: Constants.clLocation.coordinate.longitude)
            let distanceKM1 =  (coordinate1.distance(from: coordinate2))  / 1609.34
            
            let coordinate3 = CLLocation(latitude: b2b2.latitude ?? 0.0, longitude: b2b2.longitude ?? 0.0)
            let distanceKM2 =  (coordinate3.distance(from: coordinate2))  / 1609.34
            
            if distanceKM1 < distanceKM2 {
                return true
            }
            return false
        }
         
        
        self.b2bModels.removeAll()
        self.b2bModels.append(contentsOf:  B2BModel.b2bModels)
        tableView.reloadData()
        
    }
    
    
    @objc func newOfferClicked(){
        let catModel = CategoryModel()
        catModel.catName = "New Coming Offers"
        catModel.id = "n0FDkWX7PL84LhRpOn6m"
        performSegue(withIdentifier: "homeAllBusinessSeg", sender: catModel)
    }
    @objc func shoppingClicked(){
        let catModel = CategoryModel()
        catModel.catName = "Shopping"
        catModel.id = "5CFEVCBlPMjVipnCLdzB"
        performSegue(withIdentifier: "homeAllBusinessSeg", sender: catModel)
    }
    @objc func restaurantsClicked(){
        let catModel = CategoryModel()
        catModel.catName = "Restaurants"
        catModel.id = "PuAv0q4RN2BFQRwiI8KD"
        performSegue(withIdentifier: "homeAllBusinessSeg", sender: catModel)
    }
    @objc func sportsAndFitnessClicked(){
        let catModel = CategoryModel()
        catModel.catName = "Sports & Fitness"
        catModel.id = "6LEbiWfvcC82YagOz8aC"
        performSegue(withIdentifier: "homeAllBusinessSeg", sender: catModel)
    }
    @objc func entertainmentClicked(){
        let catModel = CategoryModel()
        catModel.catName = "Entertainment"
        catModel.id = "w7RRO0ymkS1aQcR503zP"
        performSegue(withIdentifier: "homeAllBusinessSeg", sender: catModel)
    }

  

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeAllBusinessSeg" {
            if let VC = segue.destination as? ShowAllBusinessesViewController {
                if let catModel = sender as? CategoryModel {
                    VC.categoryModel = catModel
                }
            }
        }
        else if segue.identifier == "homeuserBusinessDetailsSeg" {
            if let VC = segue.destination as? UserBusinessDetailsViewController {
                if let b2bModel = sender as? B2BModel {
                    VC.b2bModel = b2bModel
                }
            }
        }
    }


    @objc func showAllCategories(){
        performSegue(withIdentifier: "categorySeg", sender: nil)
    }
    
    public func updateTableViewHeight(){
        
        self.tableViewHeight.constant = self.tableView.contentSize.height
        self.tableView.layoutIfNeeded()
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    func addBorderAndCorner(view : UIView){
        view.layer.cornerRadius = 8
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
        
    }
    
    @objc func cellClicked(value : MyGesture){
        performSegue(withIdentifier: "homeuserBusinessDetailsSeg", sender: b2bModels[value.index])
    }
    
    
}

extension HomeViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

extension HomeViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        self.no_businesses_available.isHidden = b2bModels.count > 0 ? true : false
        return b2bModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "businessCell", for: indexPath) as? BusinessTableViewCell {
            
            let b2bModel = b2bModels[indexPath.row]
            
            cell.mView.layer.cornerRadius = 8
            cell.mProfile.layer.cornerRadius = 8
            if let path = b2bModel.image, !path.isEmpty {
                cell.mProfile.sd_setImage(with: URL(string: path), placeholderImage: UIImage(named: "placeholder"),options: .highPriority)
            }
            cell.mName.text = b2bModel.name ?? ""
            cell.mAddress.text = b2bModel.address ?? ""
            
            getB2BVouchersCount(by: b2bModel.uid ?? "123") { count in
                cell.mOffersCount.text = "\(count) offers"
            }
             
            let myGest = MyGesture(target: self, action: #selector(cellClicked(value: )))
            myGest.index = indexPath.row
            cell.mView.isUserInteractionEnabled = true
            cell.mView.addGestureRecognizer(myGest)
            
            let coordinate1 = CLLocation(latitude: b2bModel.latitude ?? 0.0, longitude: b2bModel.longitude ?? 0.0)
            let coordinate2 = CLLocation(latitude: Constants.clLocation.coordinate.latitude , longitude: Constants.clLocation.coordinate.longitude)
            
            let distanceKM =  (coordinate1.distance(from: coordinate2)) / 1609.34
            cell.miles.text = "\(String(format: "%.2f", distanceKM)) miles"
          
                DispatchQueue.main.async {
                    self.updateTableViewHeight()
                }
            
            
            return cell
        }
        return BusinessTableViewCell()
    }
    
}
extension HomeViewController : CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse,.authorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            self.showToast(message: "Enable Location From Settings")
            FirebaseStoreManager.db.collection("ERRORS").document(FirebaseStoreManager.auth.currentUser!.uid).setData(["date":Data(),"error":"LocationNotAuthorized"],merge: true)
        }
    }
    
  
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
 
       let userLocation = locations[0] as CLLocation
      Constants.clLocation = userLocation
    
        getAllBusinessByLocation()
        
        
        
        if i >= 3 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            locationManager = nil
        }
        
        i = i + 1
    }
}
