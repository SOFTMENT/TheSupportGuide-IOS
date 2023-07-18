//
//  ShowAllBusinessesViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 09/05/23.
//

import UIKit
import CoreLocation

class ShowAllBusinessesViewController : UIViewController {
    
    @IBOutlet weak var categoryName: UILabel!
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var noBusinessesAvailable: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var categoryModel : CategoryModel?
    var b2bModels = Array<B2BModel>()
    override func viewDidLoad() {
        guard let categoryModel = categoryModel else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        categoryName.text = categoryModel.catName ?? ""
        
        tableView.delegate = self
        tableView.dataSource = self
        
        b2bModels.append(contentsOf: getBusinessByCategory(catId: categoryModel.id ?? "123"))
        
        tableView.reloadData()
        
    
        
    }
    
    @objc func cellClicked(value : MyGesture){
        
        performSegue(withIdentifier: "userBusinessDetailsSeg", sender: b2bModels[value.index])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userBusinessDetailsSeg" {
            if let VC = segue.destination as? UserBusinessDetailsViewController {
                if let b2bModel = sender as? B2BModel {
                    VC.b2bModel = b2bModel
                }
            }
        }
    }
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
}
extension ShowAllBusinessesViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        self.noBusinessesAvailable.isHidden = b2bModels.count > 0 ? true : false
        return b2bModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "businessCell", for: indexPath) as? BusinessTableViewCell {
            
            let b2bModel = b2bModels[indexPath.row]
            
            cell.mView.layer.cornerRadius = 8
            cell.mProfile.layer.cornerRadius = 8
            if let path = b2bModel.image, !path.isEmpty {
                cell.mProfile.sd_setImage(with: URL(string: path), placeholderImage: UIImage(named: "placeholder"))
            }
            cell.mName.text = b2bModel.name ?? ""
            cell.mAddress.text = b2bModel.address ?? ""
            
            getB2BVouchersCount(by: b2bModel.uid ?? "123") { count in
                cell.mOffersCount.text = "\(count) offers"
            }
             
            let coordinate1 = CLLocation(latitude: b2bModel.latitude ?? 0.0, longitude: b2bModel.longitude ?? 0.0)
            let coordinate2 = CLLocation(latitude: Constants.clLocation.coordinate.latitude , longitude: Constants.clLocation.coordinate.longitude)
            
            let distanceKM =  (coordinate1.distance(from: coordinate2)) / 1609.34
            cell.miles.text = "\(String(format: "%.2f", distanceKM)) miles"
          
            cell.mView.isUserInteractionEnabled = true
            let myGest = MyGesture(target: self, action: #selector(cellClicked(value: )))
            myGest.index = indexPath.row
            cell.mView.addGestureRecognizer(myGest)
            
            return cell
        }
        return BusinessTableViewCell()
    }
    
}
