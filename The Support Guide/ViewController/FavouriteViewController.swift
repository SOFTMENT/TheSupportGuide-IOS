//
//  FavouriteViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 28/04/23.
//

import UIKit
import CoreLocation

class FavouriteViewController : UIViewController {
    
    @IBOutlet weak var noFavoritesAvailable: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var likeModels = Array<LikeModel>()
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        if !FirebaseStoreManager.auth.currentUser!.isAnonymous {
            ProgressHUDShow(text: "")
            getAllLike { likeModels in
                self.ProgressHUDHide()
                self.likeModels.removeAll()
                self.likeModels.append(contentsOf: likeModels ?? [])
                self.tableView.reloadData()
            }
        }
        
       
        
    }
    @objc func cellClicked(value : MyGesture){
        
        performSegue(withIdentifier: "favUserBusinessDetailsSeg", sender: value.b2bModel!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "favUserBusinessDetailsSeg" {
            if let VC = segue.destination as? UserBusinessDetailsViewController {
                if let b2bModel = sender as? B2BModel {
                    VC.b2bModel = b2bModel
                }
            }
        }
    }
}
extension FavouriteViewController  : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        self.noFavoritesAvailable.isHidden = likeModels.count > 0 ? true : false
        return likeModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "businessCell", for: indexPath) as? BusinessTableViewCell {
            
            let likeModel = likeModels[indexPath.row]
            
            getBusinessBy(uid: likeModel.b2bId ?? "123") { b2bModel in
                if let b2bModel = b2bModel {
                    cell.mView.layer.cornerRadius = 8
                    cell.mProfile.layer.cornerRadius = 8
                    if let path = b2bModel.image, !path.isEmpty {
                        cell.mProfile.sd_setImage(with: URL(string: path), placeholderImage: UIImage(named: "placeholder"))
                    }
                    cell.mName.text = b2bModel.name ?? ""
                    cell.mAddress.text = b2bModel.address ?? ""
                    
                    self.getB2BVouchersCount(by: b2bModel.uid ?? "123") { count in
                        cell.mOffersCount.text = "\(count) offers"
                    }
                     
                    let coordinate1 = CLLocation(latitude: b2bModel.latitude ?? 0.0, longitude: b2bModel.longitude ?? 0.0)
                    let coordinate2 = CLLocation(latitude: Constants.clLocation.coordinate.latitude , longitude: Constants.clLocation.coordinate.longitude)
                    
                    let distanceKM =  (coordinate1.distance(from: coordinate2)) / 1609.34
                    cell.miles.text = "\(String(format: "%.2f", distanceKM)) miles"
                  
                    cell.mView.isUserInteractionEnabled = true
                    let myGest = MyGesture(target: self, action: #selector(self.cellClicked(value: )))
                    myGest.b2bModel = b2bModel
                    cell.mView.addGestureRecognizer(myGest)
                }
                else {
                    FirebaseStoreManager.db.collection("Users").document(UserModel.data!.uid ?? "123").collection("Likes").document(b2bModel!.uid ?? "123").delete { error in
                        if error == nil{
                            self.tableView.reloadData()
                        }
                    }
                }
            }
            
 
            
            return cell
        }
        return BusinessTableViewCell()
    }
    
}
