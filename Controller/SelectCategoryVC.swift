//
//  SelectCategoryVC.swift
//  Expense Manager
//
//  Created by Andrei Vataselu on 11/14/17.
//  Copyright © 2017 Andrei Vataselu. All rights reserved.
//
import UIKit
import CoreData

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

var isCellSelected : [Bool] = []

class SelectCategoryVC: UIViewController {
    var panGestureRecognizer: UIPanGestureRecognizer!
    var percentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition!
    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var newCategoryButton : UIButton!
    @IBOutlet weak var addCategoryButton : UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGesture()
        
        let view = UIView()
        tableView.tableFooterView = view
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchCoreDataObject()
        
        addCategoryButton.isHidden = true
        
        prepareCellSelected()
    }
    
    func prepareCellSelected() {
        
        if isCellSelected.count == 0 {
            for _ in 0..<userCategories.count {
                isCellSelected.append(false)
            }
        } else {
            for _ in isCellSelected.count..<userCategories.count {
                isCellSelected.append(false)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchCoreDataObject()
        prepareCellSelected()
    }
    
    func fetchCoreDataObject() {
        fetchCategories { (complete) in
            if complete {
                if userCategories.count == 0 {
                    tableView.isHidden = true
                } else {
                    userCategories.reverse()
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
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SelectCategoryVC.handlePanGesture(_:)))
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

extension SelectCategoryVC: UINavigationControllerDelegate {
    
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

extension SelectCategoryVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as! CategoryCell
        
        cell.configureCell(title: userCategories[indexPath.row].categoryName!)
        if isCellSelected[indexPath.row] {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        if isCellSelected[indexPath.row]{
            isCellSelected[indexPath.row] = false
        } else {
            
            for i in 0..<isCellSelected.count {
                if isCellSelected[i] && i != indexPath.row {
                    isCellSelected[i] = false
                    
                    let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0))
                    cell?.accessoryType = UITableViewCellAccessoryType.none
                }
            }
            isCellSelected[indexPath.row] = true

        }
        
        let cell = tableView.cellForRow(at: indexPath)
        
        if isCellSelected[indexPath.row] {
            cell?.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell?.accessoryType = UITableViewCellAccessoryType.none
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.popViewController(animated: true)
    }
}
