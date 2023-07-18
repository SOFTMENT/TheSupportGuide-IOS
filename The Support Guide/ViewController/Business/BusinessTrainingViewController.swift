//
//  BusinessTrainingViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 31/05/23.
//


import UIKit
import Firebase
import AVFoundation
import AVKit

class BusinessTrainingViewController : UIViewController {

    
    @IBOutlet weak var noTrainingsAvailable: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var videoModels = Array<TrainingModel>()
    override func viewDidLoad() {
        tableView.dataSource = self
        tableView.delegate = self
        
        
        
        
        self.getAllTrainings(type: "b2b") { trainingModels, error in
            if let error = error {
                self.showError(error)
            }
            else {
                if let trainingModels = trainingModels {
                    self.videoModels.removeAll()
                    self.videoModels.append(contentsOf: trainingModels)
                    self.tableView.reloadData()
                }
              
            }
        }
    
    }


    
    @objc func videocCellClicked(value : MyGesture){
      
        
        let player = AVPlayer(url: URL(string: self.videoModels[value.index].videoUrl ?? "")!)
        let vc = AVPlayerViewController()
        vc.player = player

        present(vc, animated: true) {
            vc.player?.play()
        }
    }
    
    
    
}

extension BusinessTrainingViewController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.noTrainingsAvailable.isHidden = videoModels.count > 0 ? true : false
        return videoModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "videocell", for: indexPath) as? TrainingTableView {
            
            cell.mImage.layer.cornerRadius = 12
        
            
            let videoModel = videoModels[indexPath.row]
            
            cell.mName.text = videoModel.title ?? "ERROR"
            cell.mDuration.text = "\(self.convertSecondstoMinAndSec(totalSeconds: videoModel.duration ?? 0)) min"
            
            
            
            cell.mView.isUserInteractionEnabled = true
            let myTap = MyGesture(target: self, action: #selector(videocCellClicked(value:)))
            myTap.index = indexPath.row
            cell.mView.addGestureRecognizer(myTap)
          
            if let thumbnail = videoModel.thumbnail, !thumbnail.isEmpty {
                cell.mImage.sd_setImage(with: URL(string: thumbnail), placeholderImage: UIImage(named: "placeholder"))
            }
            
            return cell
        }
        return TrainingTableView()
    }
    
    
    
    
}


