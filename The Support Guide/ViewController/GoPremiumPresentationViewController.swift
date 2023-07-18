//
//  GoPremiumPresentationViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 04/05/23.
//


import UIKit
import StoreKit
import SDWebImage

class GoPremiumPresentationViewController : UIPresentationController{

   let blurEffectView: UIView!
    let createProfile : CreateProfileViewController?
   var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    var isBlurBtnSelected = false
   
  
   init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?,createProfile : CreateProfileViewController) {
    
      self.createProfile = createProfile
      blurEffectView = UIView()
      blurEffectView.backgroundColor = UIColor.clear
      
     super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
   
     tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissController(r:)))
     
      blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      self.blurEffectView.isUserInteractionEnabled = true
     blurEffectView.tag = 2
      self.blurEffectView.addGestureRecognizer(tapGestureRecognizer)
   
    
  }


    
    
    
    @objc func privacyPolicyClicked() {
        dismissController(r: UITapGestureRecognizer())
        guard let url = URL(string: "https://softment.in/terms-of-service/") else { return}
        UIApplication.shared.open(url)
    }
     
    @objc func termsOfUseClicked() {
        dismissController(r: UITapGestureRecognizer())
        guard let url = URL(string: "https://softment.in/terms-of-service/") else { return}
        UIApplication.shared.open(url)
    }
    
    
    @objc func activateBtnClicked(){
       
        if let createProfile = createProfile {
           
            if createProfile.goPremiumVC.creditDebitCheck.isSelected || createProfile.goPremiumVC.appleCheck.isSelected {
                dismissController(r: UITapGestureRecognizer())
                createProfile.activateBtnClicked()
            }
            else {
                self.createProfile?.showToast(message: "Select payment method")
            }
        }
        
       
       
        
    }

  override var frameOfPresentedViewInContainerView: CGRect {
    
      return CGRect(origin: CGPoint(x: 0, y: self.containerView!.frame.height - 628 ),
                    size: CGSize(width: self.containerView!.frame.width, height: 628))
  }

    override func presentationTransitionWillBegin() {
        
        
    
      createProfile?.goPremiumVC.activateBtn.isUserInteractionEnabled = true
      createProfile?.goPremiumVC.activateBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(activateBtnClicked)))
        
        createProfile?.goPremiumVC.termsOfUse.isUserInteractionEnabled = true
        createProfile?.goPremiumVC.termsOfUse.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(termsOfUseClicked)))
        
        createProfile?.goPremiumVC.privacyPolicy.isUserInteractionEnabled = true
        createProfile?.goPremiumVC.privacyPolicy.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(privacyPolicyClicked)))
        
        if let createProfile = createProfile {
            createProfile.goPremiumVC.dPrice.text = "$ \(createProfile.tip)"
        }
        
            
      self.containerView?.addSubview(blurEffectView)
      self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
    
      }, completion: { (UIViewControllerTransitionCoordinatorContext) in })
  }
  
  override func dismissalTransitionWillBegin() {
      self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
        
    
      }, completion: { (UIViewControllerTransitionCoordinatorContext) in
          self.blurEffectView.removeFromSuperview()
        if !self.isBlurBtnSelected {
            self.dismissController(r: UITapGestureRecognizer())
        }
        
           
      })
  }
  
  override func containerViewWillLayoutSubviews() {
      super.containerViewWillLayoutSubviews()
    presentedView!.roundCorners([.topLeft, .topRight], radius: 50)
  }

  override func containerViewDidLayoutSubviews() {
      super.containerViewDidLayoutSubviews()
      presentedView?.frame = frameOfPresentedViewInContainerView
      blurEffectView.frame = containerView!.bounds
  }

   @objc  func dismissController(r : UITapGestureRecognizer){
    if r.view?.tag == 2 {
        isBlurBtnSelected = true
    }
    else {
        isBlurBtnSelected = false
    }

    self.presentedViewController.dismiss(animated: true, completion: nil)
  }
}


extension UIView {
  func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
      let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners,
                              cornerRadii: CGSize(width: radius, height: radius))
      let mask = CAShapeLayer()
      mask.path = path.cgPath
      layer.mask = mask
  }
}
