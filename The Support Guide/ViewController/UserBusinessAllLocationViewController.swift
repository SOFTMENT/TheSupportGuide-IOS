//
//  UserBusinessAllLocationViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 12/06/23.
//

import UIKit
import CoreLocation
import MapKit

class UserBusinessAllLocationViewController : UIViewController {
    
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noStoresAvailable: UILabel!
    var storeModels = Array<StoreModel>()
    var b2bId : String?
    override func viewDidLoad() {
        
        guard let b2bId = b2bId else {
            
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.ProgressHUDShow(text: "")
        getAllStore(by: b2bId) { storeModels, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error)
            }
            else {
                self.storeModels.removeAll()
                self.storeModels.append(contentsOf: storeModels ?? [])
                self.tableView.reloadData()
            }
        }
        
        
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
    }
    private func callNumber(phoneNumber: String) {
        guard let url = URL(string: "telprompt://\(phoneNumber)"),
            UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @objc func phoneClicked(value : MyGesture){
        callNumber(phoneNumber: storeModels[value.index].phone ?? "")
    }
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    @objc func openInMapsClicked(value : MyGesture){
        showOpenMapPopup(latitude: storeModels[value.index].latitude ?? 0.0, longitude: storeModels[value.index].longitude ?? 0.0)
    }
    
    func showOpenMapPopup(latitude : Double, longitude : Double){
        let alert = UIAlertController(title: "Open in maps", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Apple Maps", style: .default, handler: { action in
            
            let coordinate = CLLocationCoordinate2DMake(latitude,longitude)
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
      
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        }))
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            
            alert.addAction(UIAlertAction(title: "Google Maps", style: .default, handler: { action in
                
                UIApplication.shared.open(URL(string:"comgooglemaps://?center=\(latitude),\(longitude)&zoom=14&views=traffic&q=\(latitude),\(longitude)")!, options: [:], completionHandler: nil)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
}
extension UserBusinessAllLocationViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noStoresAvailable.isHidden = storeModels.count > 0 ? true : false
        return storeModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "storeCell", for: indexPath) as? StoreTableViewCell {
            
            let storeModel = storeModels[indexPath.row]
            cell.storeLocation.text = storeModel.location ?? ""
            cell.storePhone.text = storeModel.phone ?? ""
            cell.storeView.layer.cornerRadius = 8
            
            let myGest = MyGesture(target: self, action: #selector(openInMapsClicked(value: )))
            myGest.index = indexPath.row
            cell.openInMaps.isUserInteractionEnabled = true
            cell.openInMaps.addGestureRecognizer(myGest)
            
            cell.storePhone.isUserInteractionEnabled = true
            let phoneGest = MyGesture(target: self, action: #selector(phoneClicked(value: )))
            phoneGest.index = indexPath.row
            cell.storePhone.addGestureRecognizer(phoneGest)
            
            return cell
        }
        return StoreTableViewCell()
    }
    
    
    
}
