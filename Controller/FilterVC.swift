//
//  FilterVC.swift
//  Expense Manager
//
//  Created by Andrei Vataselu on 11/15/17.
//  Copyright © 2017 Andrei Vataselu. All rights reserved.
//

import UIKit
import Foundation
import QuartzCore

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

var andPredicatesArray : [NSPredicate] = []
var orPredicatesArray : [NSPredicate] = []
var isFilteringSections = false

class FilterVC: UIViewController {

    var panGestureRecognizer: UIPanGestureRecognizer!
    var percentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition!
    var sectionsCount = 1
    
    var filterCell : [[Bool]] = [[]]
    
    @IBOutlet weak var tableView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGesture()
        
        andPredicatesArray = []
        orPredicatesArray = []
        
        fetchCategories { (_) in}
        initiateFilterCellArray()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    func initiateFilterCellArray() {
        filterCell.append([])
        filterCell[0].append(false)
        filterCell[0].append(false)
        
        filterCell.append([])

        for _ in 0..<userCategories.count {
            filterCell[1].append(false)
        }
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
    
    @IBAction func backBtnPressed (_ sender: Any){
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func okButtonPressed (_ sender: Any){
        
        
        if filterCell[0][0] && filterCell[0][1] {
            andPredicatesArray.append(NSPredicate(format: "(type == %@) OR (type == %@)", "budget" as NSString, "expense" as NSString))
        } else if filterCell[0][0] {
            andPredicatesArray.append(NSPredicate(format: "type == %@", "budget" as NSString))
        } else if filterCell[0][1] {
            andPredicatesArray.append(NSPredicate(format: "type == %@", "expense" as NSString))
        }
        
        for i in 0..<filterCell[1].count {
            if filterCell[1][i] {
                orPredicatesArray.append(NSPredicate(format: "(category == %@) OR (type == %@)", userCategories[i], "budget" as NSString))
            }
        }
        
        isFilteringSections = true
        navigationController?.popViewController(animated: true)
    }
    
}

extension FilterVC: UINavigationControllerDelegate {
    
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


extension FilterVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsCount
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return NSLocalizedString("entryType", comment: "")
        } else {
            return NSLocalizedString("categoriesToPick", comment: "")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 50.0
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return userCategories.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell") as! PickCategoryCell
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.labelView.text = NSLocalizedString("budgetType", comment: "")
            } else {
                cell.labelView.text = NSLocalizedString("expenseType", comment: "")
            }
        } else {
            cell.labelView.text = userCategories[indexPath.row].categoryName
            
            if filterCell[1][indexPath.row] {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.none
            }
        }
        
        return cell
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if filterCell[indexPath.section][indexPath.row]{
                filterCell[indexPath.section][indexPath.row] = false
                
                if indexPath.row == 1 && userCategories.count != 0{
                sectionsCount -= 1
                }
                
            } else {
                
                filterCell[0][indexPath.row] = true
                if indexPath.row == 1 && userCategories.count != 0 {
                    for _ in 0..<userCategories.count {
                        filterCell[1].append(false)
                    }
                    sectionsCount += 1
                    for i in 0..<filterCell[1].count {
                        filterCell[1][i] = false
                    }
                }
            }
            
            let cell = tableView.cellForRow(at: indexPath)
            
            if filterCell[0][indexPath.row] {
                cell?.accessoryType = UITableViewCellAccessoryType.checkmark
            } else {
                cell?.accessoryType = UITableViewCellAccessoryType.none
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
            
            
            let transition = CATransition()
            transition.type = kCATransitionFade
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.fillMode = kCAFillModeForwards
            transition.duration = 0.3
            transition.subtype = kCATransitionReveal
            self.tableView.layer.add(transition, forKey: "UITableViewReloadDataAnimationKey")
            self.tableView.reloadData()

        } else {
          
            if filterCell[1][indexPath.row] {
                filterCell[1][indexPath.row] = false
            } else {
                filterCell[1][indexPath.row] = true
     
            }
            
            let cell = tableView.cellForRow(at: indexPath)
            
            if filterCell[1][indexPath.row] {
                cell?.accessoryType = UITableViewCellAccessoryType.checkmark
            } else {
                cell?.accessoryType = UITableViewCellAccessoryType.none
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
}
