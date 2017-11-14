//
//  CategoriesVC.swift
//  Expense Manager
//
//  Created by Andrei Vataselu on 11/13/17.
//  Copyright © 2017 Andrei Vataselu. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

var userCategories : [Categories] = []

class CategoriesVC: UIViewController {
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    var percentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition!
    
    @IBOutlet weak var tableView : UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGesture()
        
        let view = UIView()
        tableView.tableFooterView = view
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchCoreDataObject()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchCoreDataObject()
    }
    
    func fetchCoreDataObject() {
        fetchCategories { (complete) in
            if complete {
                if userCategories.count == 0 {
                    tableView.isHidden = true
                } else {
                    tableView.reloadData()
                    tableView.isHidden = false
                }
            }
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addGesture() {
        
        guard navigationController?.viewControllers.count > 1 else {
            return
        }
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(CategoriesVC.handlePanGesture(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func handlePanGesture(_ panGesture: UIPanGestureRecognizer) {
        
        let percent = max(panGesture.translation(in: view).x, 0) / view.frame.width
        
        switch panGesture.state {
            
        case .began:
            navigationController?.delegate = self
            _ = navigationController?.popViewController(animated: true)
            
        case .changed:
            if let percentDrivenInteractiveTransition = percentDrivenInteractiveTransition {
                percentDrivenInteractiveTransition.update(percent)
            }
            
        case .ended:
            let velocity = panGesture.velocity(in: view).x
            
            // Continue if drag more than 50% of screen width or velocity is higher than 1000
            if percent > 0.5 || velocity > 1000 {
                percentDrivenInteractiveTransition.finish()
            } else {
                percentDrivenInteractiveTransition.cancel()
            }
            
        case .cancelled, .failed:
            percentDrivenInteractiveTransition.cancel()
            
        default:
            break
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addCategory(_ sender: UIButton) {
        let addCatVC = storyboard?.instantiateViewController(withIdentifier: "AddCategoryVC")
        navigationController?.pushViewController(addCatVC!, animated: true)
    }

}

extension CategoriesVC: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return SlideAnimatedTransitioning()
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        navigationController.delegate = nil
        
        if panGestureRecognizer.state == .began {
            percentDrivenInteractiveTransition = UIPercentDrivenInteractiveTransition()
            percentDrivenInteractiveTransition.completionCurve = .easeOut
        } else {
            percentDrivenInteractiveTransition = nil
        }
        
        return percentDrivenInteractiveTransition
    }
    
}

extension CategoriesVC : UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
    

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else {return nil}
        
        let deleteAction = SwipeAction(style: .destructive, title: "Sterge") { (action, indexPath) in

            guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
            
            managedContext.delete(userCategories[indexPath.row])
            
            do {
                try managedContext.save()
            } catch {}
            
            self.fetchCoreDataObject()
            tableView.reloadData()
            
        }
        deleteAction.backgroundColor = red
        
        return [deleteAction]
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as! CategoryCell
        
        cell.configureCell(title: userCategories[indexPath.row].categoryName!)
        cell.delegate = self
        
        return cell
    }
    
    
    
}
