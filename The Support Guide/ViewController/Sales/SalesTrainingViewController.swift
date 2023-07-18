//
//  SalesTrainingViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 31/05/23.
//

import UIKit

class SalesTrainingViewController : UIViewController {
    
    @IBOutlet weak var watchOnYoutube: UIView!
    override func viewDidLoad() {
        watchOnYoutube.layer.cornerRadius = 8
        watchOnYoutube.dropShadow()
        watchOnYoutube.isUserInteractionEnabled = true
        watchOnYoutube.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(watchOnYouTubeClicked)))
    }
    
    @objc func watchOnYouTubeClicked(){
        guard let url = URL(string: "https://youtube.com/playlist?list=PLcPC1WslMoghnq7jk_6v5dTBdOPaoPVjl") else { return}
        UIApplication.shared.open(url)
    }
    
}
