//
//  BusinessReportViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 02/06/23.
//

import UIKit

class BusinessReportViewController : UIViewController {
    
    @IBOutlet weak var offerClaimedView: UIView!
    @IBOutlet weak var offerClickedView: UIView!
    @IBOutlet weak var googleReviewView: UIView!
    
    @IBOutlet weak var offerClaimedCount: UILabel!
    @IBOutlet weak var offerClickedCount: UILabel!
    @IBOutlet weak var googleReviewCount: UILabel!
  
    override func viewDidLoad() {
  
        offerClaimedView.layer.cornerRadius = 8
        offerClickedView.layer.cornerRadius = 8
        googleReviewView.layer.cornerRadius = 8
        
        ProgressHUDShow(text: "")
        
        let query = FirebaseStoreManager.db.collection("Businesses").document(B2BModel.data!.uid ?? "123").collection("GoogleReviews")
        let countQuery = query.count
        
            countQuery.getAggregation(source: .server) { snapshot, error in
                if let snapshot = snapshot{
                    
                    self.googleReviewCount.text = "\(snapshot.count)"
                }
                
            }
        
        let query2 = FirebaseStoreManager.db.collection("Businesses").document(B2BModel.data!.uid ?? "123").collection("PageVisits")
        let countQuery2 = query2.count
        
            countQuery2.getAggregation(source: .server) { snapshot, error in
                if let snapshot = snapshot{
                    
                    self.offerClickedCount.text = "\(snapshot.count)"
                }
                
            }
        
        let query1 = FirebaseStoreManager.db.collection("RedeemHistory").whereField("b2bId", isEqualTo: B2BModel.data!.uid ?? "123")
        let countQuery1 = query1.count
        
            countQuery1.getAggregation(source: .server) { snapshot, error in
                self.ProgressHUDHide()
                if let snapshot = snapshot{
                    
                    self.offerClaimedCount.text = "\(snapshot.count)"
                }
                
            }
    }
    
}
