//
//  VoucherSuccessfulRedemeedViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 12/06/23.
//

import UIKit
import Lottie

class VoucherSuccessfulRedemeedViewController : UIViewController {
    
    @IBOutlet weak var dashboardBtn: UIButton!
    @IBOutlet weak var lottieAnimation: LottieAnimationView!
    @IBOutlet weak var time: UILabel!
    
    override func viewDidLoad() {
        lottieAnimation.loopMode = .loop
        lottieAnimation.play()
    
        dashboardBtn.isUserInteractionEnabled = true
        
        time.text = convertDateForVoucher(Date())
    
    }
    
    @IBAction func dashboardClicked(_ sender: Any) {
        self.beRootScreen(mIdentifier: Constants.StroyBoard.tabBarViewController)
    }
}
