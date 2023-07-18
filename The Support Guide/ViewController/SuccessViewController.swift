//
//  SuccessViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 27/04/23.
//

import UIKit
import Lottie

class SuccessViewController : UIViewController {
    
    
    @IBOutlet weak var lottieAnimation: LottieAnimationView!
    
    override func viewDidLoad() {
        lottieAnimation.loopMode = .loop
        lottieAnimation.play()
        
      
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.beRootScreen(mIdentifier: Constants.StroyBoard.tabBarViewController)
        }
        
       
        
    }
    
}
