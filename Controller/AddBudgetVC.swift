//
//  AddBudgetVC.swift
//  Expense Manager
//
//  Created by Andrei Vataselu on 10/4/17.
//  Copyright © 2017 Andrei Vataselu. All rights reserved.
//

import UIKit

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

var btc = NSLayoutConstraint()

class AddBudgetVC: UIViewController {

    @IBOutlet weak var userBudgetLabel: UILabel!
    @IBOutlet weak var sumText: UITextField!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var descriptionText: UITextField!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var percentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition!
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        
        btc = bottomConstraint
        
        if userMoney.count > 0 {
            userBudgetLabel.text = replaceLabel(number: userMoney[userMoney.count - 1].userMoney)
        }
                
        addBtn.bindToKeyboard()
        addBtn.translatesAutoresizingMaskIntoConstraints = false
        
        addGesture()
    }
    
    func addGesture() {
        
        guard navigationController?.viewControllers.count > 1 else {
            return
        }

        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(AddBudgetVC.handlePanGesture(_:)))
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
    
    @IBAction func backBtnPressed(_ sender: Any) {
        print("SENDER: add budget")
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addBtnPressed(_ sender: Any) {
        
        var descriptionCheck = descriptionText.text!
        if descriptionCheck == "" {
            descriptionCheck = "Buget adaugat"
        }
        
        if sumText.text == ""  {
           sumInvalidAlert()
        } else {
            userMoney[userMoney.count - 1 ].userMoney += (sumText.text! as NSString).doubleValue
            self.saveMoney(userMoney: userMoney[userMoney.count - 1].userMoney, completion: { (complete) in
            })
            self.save(sumText: sumText.text! , dataDescription: descriptionCheck, dataColor: green) { complete in
            if complete {
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
}
}

extension AddBudgetVC : UINavigationControllerDelegate {
    
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
