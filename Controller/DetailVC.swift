//
//  DetailVC.swift
//  Expense Manager
//
//  Created by Andrei Vataselu on 11/17/17.
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

class DetailVC: UIViewController {
    
    @IBOutlet weak var sumText : UILabel!
    @IBOutlet weak var descriptionText : UILabel!
    @IBOutlet weak var categoryText : UILabel!
    @IBOutlet weak var dateText : UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    var percentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition!

    override func viewDidLoad() {
        super.viewDidLoad()
        sumText.text = "\(detailData[0]) \(Locale.current.currencySymbol!)"
        descriptionText.text = detailData[1]
        categoryText.text = detailData[2]
        dateText.text = detailData[3]
        
        if detailData[4] == "budget" {
            typeLabel.text = NSLocalizedString("budgetType", comment: "")
            sumText.textColor = green
        } else {
            typeLabel.text = NSLocalizedString("expenseType", comment: "")
            sumText.textColor = red
        }
        
        addGesture()
    
    }
    
    @IBAction func backBtnPressed(_ sender: Any){
        navigationController?.popViewController(animated: true)
    }
    
    func addGesture() {
        
        guard navigationController?.viewControllers.count > 1 else {
            return
        }
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DetailVC.handlePanGesture(_:)))
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension DetailVC: UINavigationControllerDelegate {
    
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
