//
//  BusinessAddStoreViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 10/06/23.
//


import UIKit

class BusinessEditStoreViewController : UIViewController {
    
    
    @IBOutlet weak var deleteView: UIView!
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
    var storeModel : StoreModel?
    override func viewDidLoad() {
        
        guard let storeModel = storeModel else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        fAddress.text = storeModel.location ?? ""
        phoneNumber.text = storeModel.phone ?? ""
        latitude = storeModel.latitude ?? 0.0
        longitude = storeModel.longitude ?? 0.0
        
        
        fAddress.delegate = self
        fAddress.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        
        fAddressTable.delegate = self
        fAddressTable.dataSource = self
        fAddressTable.isScrollEnabled = false
        fAddressTable.contentInsetAdjustmentBehavior = .never
        
        phoneNumber.delegate = self
        
        addBtn.layer.cornerRadius = 8
        
        deleteView.isUserInteractionEnabled = true
        deleteView.dropShadow()
        deleteView.layer.cornerRadius = 8
        deleteView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteStoreClicked)))
        
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    @objc func deleteStoreClicked(){
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this store?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            self.ProgressHUDShow(text: "Deleting...")
            FirebaseStoreManager.db.collection("Businesses").document(B2BModel.data!.uid ?? "123").collection("Stores").document(self.storeModel!.id ?? "123").delete { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                }
                else {
                    self.showToast(message: "Deleted")
                    let seconds = 2.0
                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                        self.dismiss(animated: true)
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
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
            
          
            self.storeModel!.latitude = self.latitude
            self.storeModel!.longitude = self.longitude
            self.storeModel!.location = sAddress
            self.storeModel!.phone = sPhone
            
            let collectionRef = FirebaseStoreManager.db.collection("Businesses").document(B2BModel.data!.uid ?? "123").collection("Stores")
            
          
            
            try? collectionRef.document(self.storeModel!.id!).setData(from: self.storeModel!) { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                }
                else {
                    self.showToast(message: "Store Updated")
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
extension BusinessEditStoreViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        view.endEditing(true)
        return true
    }
}
extension BusinessEditStoreViewController : UITableViewDelegate, UITableViewDataSource {
    
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
