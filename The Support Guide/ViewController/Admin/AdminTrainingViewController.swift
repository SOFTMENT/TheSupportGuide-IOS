//
//  AdminTrainingViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 18/05/23.
//


import UIKit
import Firebase
import AVFoundation
import AVKit

class AdminTrainingViewController : UIViewController {
    
    
    @IBOutlet weak var addView: UIImageView!
    
    @IBOutlet weak var noTrainingsAvailable: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var videoModels = Array<TrainingModel>()
    override func viewDidLoad() {
        tableView.dataSource = self
        tableView.delegate = self
        
        
        loadTrainingVideos(type: "franchise")
        
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributes, for: .selected)
        
        addView.isUserInteractionEnabled = true
        addView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addTrainingClicked)))
    }

    @IBAction func segmentClicked(_ sender: UISegmentedControl) {
    
        if sender.selectedSegmentIndex == 0 {
            loadTrainingVideos(type: "franchise")
          
        }
        else {
            loadTrainingVideos(type: "b2b")
        }

    }
    
    func loadTrainingVideos(type : String){
        ProgressHUDShow(text: "")
        self.getAllTrainings(type: type ) { trainingModels, error in
            self.ProgressHUDHide()
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
    
    @objc func addTrainingClicked(){
        self.performSegue(withIdentifier: "addTrainingSeg", sender: nil)
    }
    
    @objc func videocCellClicked(value : MyGesture){
      
        
        let player = AVPlayer(url: URL(string: self.videoModels[value.index].videoUrl ?? "")!)
        let vc = AVPlayerViewController()
        vc.player = player

        present(vc, animated: true) {
            vc.player?.play()
        }
    }
    
    @objc func deleteVideo(value : MyGesture){
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this video?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive,handler: { action in
            self.ProgressHUDShow(text: "Deleting...")
            FirebaseStoreManager.db.collection("Trainings").document(value.id).delete { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                }
                else {
                    self.showToast(message: "Video Deleted")
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
}

extension AdminTrainingViewController : UITableViewDelegate , UITableViewDataSource {
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
            
            cell.mDelete.isUserInteractionEnabled  = true
            let deleteGest = MyGesture(target: self, action: #selector(deleteVideo(value: )))
            deleteGest.id = videoModel.id ?? "123"
            cell.mDelete.addGestureRecognizer(deleteGest)
            
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

