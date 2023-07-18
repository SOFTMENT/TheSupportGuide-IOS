//
//  GoPremiumViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 30/04/23.
//

import UIKit
import Lottie

class GoPremiumViewController: UIViewController {
    @IBOutlet weak var animation: LottieAnimationView!
    @IBOutlet weak var mPrice: UILabel!
    @IBOutlet weak var activateBtn: UIButton!
    @IBOutlet weak var termsOfUse: UILabel!
    @IBOutlet weak var privacyPolicy: UILabel!
    @IBOutlet weak var appleCheck: UIButton!
    @IBOutlet weak var creditDebitCheck: UIButton!
    
    @IBOutlet weak var dPrice: UILabel!
    @IBOutlet weak var donationFeeView: UIView!
    
    @IBOutlet weak var membershipFeeView: UIView!
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)

        membershipFeeView.layer.cornerRadius = 8
        membershipFeeView.dropShadow()
        
        donationFeeView.layer.cornerRadius = 8
        donationFeeView.dropShadow()
        
        activateBtn.layer.cornerRadius = 8
        animation.loopMode = .loop
        animation.play()
        
        // Do any additional setup after loading the view.
    }

    @IBAction func creditDebitClicked(_ sender: Any) {
        appleCheck.isSelected = false
        creditDebitCheck.isSelected = true
    }
    @IBAction func applePayClicked(_ sender: UIButton) {
        appleCheck.isSelected = true
        creditDebitCheck.isSelected = false
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }
        
        // setting x as 0 because we don't want users to move the frame side ways!! Only want straight up or down
         view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
    
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 {
                self.dismiss(animated: true, completion: nil)
            } else {
                // Set back to original position of the view controller
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
}
