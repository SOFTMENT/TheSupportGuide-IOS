//
//  LocationFilterViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 11/06/23.
//

import UIKit

protocol LocationEnteredDelegate: AnyObject {
    func userDidEnterLocation(latitude : Double, longitude : Double)
}

class LocationFilterViewController : UIViewController {
    
    @IBOutlet weak var enterLocationTF: UITextField!
  
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var addLocationBtn: UIButton!
    @IBOutlet weak var locationTableView: UITableView!
    var places : [Place] = []
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var isLocationSelected : Bool = false
    var place : Place?
    weak var delegate: LocationEnteredDelegate? = nil
    override func viewDidLoad() {
        
        enterLocationTF.layer.cornerRadius = 8
        enterLocationTF.delegate = self
        enterLocationTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
    
        addLocationBtn.layer.cornerRadius = 8
        
        locationTableView.delegate = self
        locationTableView.dataSource = self
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    @objc func textFieldDidChange(textField : UITextField){
        guard let query = textField.text, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            self.places.removeAll()
        
            self.locationTableView.reloadData()
            return
        }
        
        
        GooglePlacesManager.shared.findPlaces(query: query ) { result in
            switch result {
            case .success(let places) :
                self.places = places
                print(self.places)
                self.locationTableView.reloadData()
                break
            case .failure(let error) :
                print(error)
            }
        }
    }
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    
    @IBAction func addLocationClicked(_ sender: Any) {
        if self.place == nil {
      
            self.showToast(message: "Enter Location")
        }
        else {
            delegate?.userDidEnterLocation(latitude: self.latitude, longitude: self.longitude)
            self.dismiss(animated: true)
        }
    }
    @objc func locationCellClicked(myGesture : MyGesture){
        locationTableView.isHidden = true
        view.endEditing(true)

        let place = places[myGesture.index]
        self.place = place
       enterLocationTF.text = place.name ?? ""
        
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
    
}
extension LocationFilterViewController : UITableViewDelegate, UITableViewDataSource {
    
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
            
            
            cell.name.text = places[indexPath.row].name ?? ""
            cell.mView.isUserInteractionEnabled = true
            
            let myGesture = MyGesture(target: self, action: #selector(locationCellClicked(myGesture:)))
            myGesture.index = indexPath.row
            cell.mView.addGestureRecognizer(myGesture)
          
            return cell
        }
        
        return Google_Places_Cell()
    }
    
    
    
}

extension LocationFilterViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}
