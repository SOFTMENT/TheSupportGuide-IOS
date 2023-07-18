//
//  BusinessDetailsViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 10/06/23.
//

import UIKit
import MapKit

class BusinessDetailsViewController : UIViewController {
    @IBOutlet weak var titleHead: UILabel!
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var mProfile: UIImageView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var businessName: UILabel!
    @IBOutlet weak var businessEmail: UILabel!
    @IBOutlet weak var businessPhone: UILabel!
    @IBOutlet weak var businessLocation: UILabel!
    @IBOutlet weak var openingTime: UILabel!
    @IBOutlet weak var closingTime: UILabel!
    @IBOutlet weak var aboutBusiness: UILabel!
    @IBOutlet weak var addStore: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var noStoresAvailable: UILabel!
    var storeModels = Array<StoreModel>()
    var fromAdminPanel : Bool?
    var b2bModel : B2BModel?
    override func viewDidLoad() {
      
        guard let b2bModel = b2bModel else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        mProfile.layer.cornerRadius = 8
        
        if let path = b2bModel.image, !path.isEmpty {
            mProfile.sd_setImage(with: URL(string: path), placeholderImage: UIImage(named: "profile-placeholder"))
        }
        
        editBtn.layer.cornerRadius = 6
        editBtn.dropShadow()
        
        addStore.isUserInteractionEnabled = true
        addStore.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addStoreClicked)))
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.ProgressHUDShow(text: "")
        getAllStore(by: b2bModel.uid ?? "123") { storeModels, error in
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
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {

        guard let b2bModel = b2bModel else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        if let fromAdminPanel = fromAdminPanel, fromAdminPanel {
            DispatchQueue.main.async {
                self.addStore.isHidden = true
                self.editBtn.isHidden = true
                self.titleHead.text = self.b2bModel!.name ?? ""
            }
            
        }
        
        businessName.text = b2bModel.name ?? ""
        businessEmail.text = b2bModel.email ?? ""
        businessPhone.text = b2bModel.phoneNumber ?? ""
        businessLocation.text = b2bModel.address ?? ""
        
        openingTime.text = self.convertDateIntoTimeForRecurringVoucher(b2bModel.openingTime ?? Date())
        closingTime.text = self.convertDateIntoTimeForRecurringVoucher(b2bModel.closingTime ?? Date())
        
        aboutBusiness.text = b2bModel.aboutBusiness ?? ""
        
        
    }
    
    @objc func addStoreClicked(){
        performSegue(withIdentifier: "addStoreSeg", sender: nil)
    }
    
    @IBAction func editBtnClicked(_ sender: Any) {
        performSegue(withIdentifier: "details_editSeg", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "details_editSeg" {
            if let VC = segue.destination as? FranchiseEditBusinessController {
                VC.b2bModel = self.b2bModel
            }
        }
        else if  segue.identifier == "editStoreSeg" {
            if let VC = segue.destination as? BusinessEditStoreViewController {
                if let storeModel = sender as? StoreModel {
                    VC.storeModel = storeModel
                }
            }
        }
    }
    
    @objc func openInMapsClicked(value : MyGesture){
        showOpenMapPopup(latitude: storeModels[value.index].latitude ?? 0.0, longitude: storeModels[value.index].longitude ?? 0.0)
    }
    
    public func updateTableViewHeight(){
        
        self.tableViewHeight.constant = self.tableView.contentSize.height
        self.tableView.layoutIfNeeded()
    }
    
    func showOpenMapPopup(latitude : Double, longitude : Double){
        let alert = UIAlertController(title: "Open in maps", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Apple Maps", style: .default, handler: { action in
            
            let coordinate = CLLocationCoordinate2DMake(latitude,longitude)
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
            mapItem.name = self.b2bModel!.name ?? ""
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
    
    @objc func storeCellClicked(value : MyGesture){
        
        performSegue(withIdentifier: "editStoreSeg", sender: storeModels[value.index])
    }
}

extension BusinessDetailsViewController : UITableViewDelegate, UITableViewDataSource {
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
            
            cell.storeView.isUserInteractionEnabled = true
            let storeEditGest = MyGesture(target: self, action: #selector(storeCellClicked(value:)))
            storeEditGest.index = indexPath.row
            cell.storeView.addGestureRecognizer(storeEditGest)
            
            
            DispatchQueue.main.async {
                self.updateTableViewHeight()
            }
            return cell
        }
        return StoreTableViewCell()
    }
    
    
    
}
