//
//  MapViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 28/04/23.
//
import UIKit
import MapKit

import Firebase

class MapViewController : UIViewController {

    @IBOutlet weak var locationFilterBtn: UIImageView!
    @IBOutlet weak var filterByCatBtn: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var totalOffers: UILabel!
    @IBOutlet weak var miles: UILabel!
    var region : MKCoordinateRegion?
    
    var storeModels = Array<B2BModel>()
   
    override func viewDidLoad() {
        
        locationView.layer.cornerRadius = 8
        locationImage.layer.cornerRadius = 8
        mapView.delegate = self
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideInstructorView)))
        
        filterByCatBtn.isUserInteractionEnabled = true
        filterByCatBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(catFilterClicked)))
        
        locationFilterBtn.isUserInteractionEnabled = true
        locationFilterBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(locationFilterClicked)))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "filterByLocationSeg" {
            if let VC = segue.destination as? LocationFilterViewController {
                VC.delegate = self
            }
        }
        else if segue.identifier == "mapBusinessDetailsSeg" {
            if let VC = segue.destination as? UserBusinessDetailsViewController {
                if let b2bModel = sender as? B2BModel {
                    VC.b2bModel = b2bModel
                }
            }
        }
    }
    
    @objc func locationFilterClicked(){
        performSegue(withIdentifier: "filterByLocationSeg", sender: nil)
    }
    
    @objc func catFilterClicked(){
        let alert = UIAlertController(title: nil, message: "Filter By Category", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Select All", style: .default,handler: { action in
           
            self.filterBusiness(id: "")
           
        }))
        
        alert.addAction(UIAlertAction(title: "New Coming Offers", style: .default,handler: { action in
           
            self.filterBusiness(id: "")
           
        }))
        for catModel in CategoryModel.catModels {
        
            alert.addAction(UIAlertAction(title: catModel.catName ?? "123", style: .default,handler: { error in
                self.filterBusiness(id: catModel.id ?? "123")
                
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
        
    }
    
    func filterBusiness(id : String){
        self.storeModels.removeAll()
        if id == "" {
            self.storeModels.append(contentsOf: B2BModel.b2bModels)
        }
        else {
            self.storeModels.append(contentsOf:  self.getBusinessByCategory(catId: id))
        }
        self.loadAnotation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        storeModels.removeAll()
        storeModels.append(contentsOf: B2BModel.b2bModels)
        loadAnotation()
    }
    
    
    
    
    @objc func locatonViewCliced(value : MyGesture){
        let model = storeModels[value.index]
        performSegue(withIdentifier: "mapBusinessDetailsSeg", sender: model)

    }
    
    @objc func hideInstructorView(){
        self.locationView.isHidden = true
    }
    

  
    
    func loadAnotation() {
        mapView.removeAnnotations(mapView.annotations)
        var i = 0
        for model in storeModels {
            let annotation =  CustomAnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: model.latitude ?? 0.0, longitude: model.longitude ?? 0.0)
            annotation.title = model.name ?? "Business Name"
            annotation.subtitle = model.catName ?? "Something Went Wrong"
            annotation.position = i
    
            mapView.addAnnotation(annotation)
            if i == 0 {
                if region == nil {
                    region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters:6000,longitudinalMeters: 6000)
                }
                mapView.setRegion(region!, animated: true)
                
            }
            
            i = i + 1
        }
        
      
    }
  
    
 
}


extension MapViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
            
            
            if let customAnotation  = annotation as? CustomAnotation {
                locationView.isHidden =  false
                let model = storeModels[customAnotation.position]
                locationName.text = model.name ?? "Name"
                address.text = model.address ?? "Something Went Wrong"
                
                if let sImage = model.image, !sImage.isEmpty {
                    locationImage.sd_setImage(with: URL(string: sImage), placeholderImage: UIImage(named: "placeholder"), options: .continueInBackground, completed: nil)
                }
                
                getB2BVouchersCount(by: model.uid ?? "123") { count in
                    self.totalOffers.text = "\(count)"
                }
                 
                let coordinate1 = CLLocation(latitude: model.latitude ?? 0.0, longitude: model.longitude ?? 0.0)
                let coordinate2 = CLLocation(latitude: Constants.clLocation.coordinate.latitude , longitude: Constants.clLocation.coordinate.longitude)
                
                let distanceKM =  (coordinate1.distance(from: coordinate2)) / 1609.34
                miles.text = "\(String(format: "%.2f", distanceKM)) Miles"
                
                locationView.isUserInteractionEnabled = true
                let myTap = MyGesture(target: self, action: #selector(locatonViewCliced(value:)))
                myTap.index = customAnotation.position
                locationView.addGestureRecognizer(myTap)
                
            }
           
            
        }
        
    }
}

class CustomAnotation : MKPointAnnotation {
    
    var position : Int = 0
    
}

extension MapViewController : LocationEnteredDelegate {
    func userDidEnterLocation(latitude: Double, longitude: Double) {
        region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), latitudinalMeters:6000,longitudinalMeters: 6000)
        mapView.setRegion(region!, animated: true)
    }
}
