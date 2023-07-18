//
//  BusinessAddStoreViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 10/06/23.
//


import UIKit

class BusinessAddStoreViewController : UIViewController {
    
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var fAddressTable: UITableView!
    @IBOutlet weak var fTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var fAddress: UITextField!
    var places : [Place] = []
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var isLocationSelected = false
    override func viewDidLoad() {
        
        fAddress.delegate = self
        fAddress.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        
        fAddressTable.delegate = self
        fAddressTable.dataSource = self
        fAddressTable.isScrollEnabled = false
        fAddressTable.contentInsetAdjustmentBehavior = .never
        
        phoneNumber.delegate = self
        
        addBtn.layer.cornerRadius = 8
        
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    @objc func backViewClicked(){
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
    
    @IBAction func addBtnClicked(_ sender: Any) {
        
        let sPhone = phoneNumber.text
        let sAddress = fAddress.text
        if !isLocationSelected || sAddress == "" {
            self.showToast(message: "Enter Address")
        }
        else if sPhone == "" {
            self.showToast(message: "Enter Phone Number")
        }
        else {
            self.ProgressHUDShow(text: "")
            
            let storeModel = StoreModel()
            storeModel.latitude = self.latitude
            storeModel.longitude = self.longitude
            storeModel.location = sAddress
            storeModel.phone = sPhone
            
            let collectionRef = FirebaseStoreManager.db.collection("Businesses").document(B2BModel.data!.uid ?? "123").collection("Stores")
            
            storeModel.date = Date()
            storeModel.id = collectionRef.document().documentID
            
            try? collectionRef.document(storeModel.id!).setData(from: storeModel) { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                }
                else {
                    self.showToast(message: "Store Added")
                    let seconds = 2.2
                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                        self.dismiss(animated: true)
                    }
                }
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
}
extension BusinessAddStoreViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        view.endEditing(true)
        return true
    }
}
extension BusinessAddStoreViewController : UITableViewDelegate, UITableViewDataSource {
    
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
