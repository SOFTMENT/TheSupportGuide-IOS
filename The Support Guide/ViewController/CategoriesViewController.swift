//
//  CategoriesViewController.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 08/05/23.
//

import UIKit

class CategoriesViewController : UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var no_categories_available: UILabel!
    var categoryModels = Array<CategoryModel>()
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        backView.isUserInteractionEnabled = true
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
    
        self.categoryModels.append(contentsOf: CategoryModel.catModels)
        self.tableView.reloadData()
        
    }
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
    @objc func cellClicked(value : MyGesture){
        performSegue(withIdentifier: "catShowAllBusinessSeg", sender: categoryModels[value.index])
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "catShowAllBusinessSeg" {
            if let VC = segue.destination as? ShowAllBusinessesViewController {
                if let catModel = sender as? CategoryModel {
                    VC.categoryModel = catModel
                }
            }
        }
    }
}

extension CategoriesViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        no_categories_available.isHidden = categoryModels.count > 0 ? true : false
        return categoryModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "categoriesCell", for: indexPath) as? CategoriesTableViewCell {
            
            let categoryModel = self.categoryModels[indexPath.row]
            cell.mView.layer.cornerRadius = 8
            cell.mTitle.text = categoryModel.catName ?? ""
            
            cell.mView.isUserInteractionEnabled = true
            let myGest = MyGesture(target: self, action: #selector(cellClicked))
            myGest.index = indexPath.row
            cell.mView.addGestureRecognizer(myGest)
            
            return cell
        }
        return CategoriesTableViewCell()
    }
    
    
    
    
}
