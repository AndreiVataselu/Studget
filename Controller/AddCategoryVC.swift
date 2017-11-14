//
//  AddCategoryVC.swift
//  Expense Manager
//
//  Created by Andrei Vataselu on 11/13/17.
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

class AddCategoryVC: UIViewController {

    var panGestureRecognizer: UIPanGestureRecognizer!
    var percentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition!

    
    @IBOutlet weak var addBtn : UIButton!
    @IBOutlet weak var textField : UITextField!
    
    @IBOutlet weak var addBtnConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btc = addBtnConstraint
        btc.constant = 0
        addBtn.bindToKeyboard()
        
        addGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        btc = addBtnConstraint
        btc.constant = 0
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
    
    @IBAction func addBtnPressed(_ sender: UIButton) {
        if textField.text == "" {
            let alertController = UIAlertController(title: "Nicio categorie introdusa", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alertController.addAction(okAction)
            present(alertController, animated: true)
        } else {
            
            var categoryAlreadyExists = false
            var categoryName = ""
            for category in userCategories {
                if category.categoryName == textField.text {
                    categoryAlreadyExists = true
                    categoryName = textField.text!
                }
            }
            
            if categoryAlreadyExists {
                let alreadyExistingCategoryController = UIAlertController(title: "Categoria \(categoryName) exista deja.", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alreadyExistingCategoryController.addAction(okAction)
                present(alreadyExistingCategoryController, animated: true)
            
            } else {
                self.saveCategory(category: textField.text!, completion: { complete in
                    if complete {
                        navigationController?.popViewController(animated: true)
                    }
                })
            }
        }
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

}

extension AddCategoryVC: UINavigationControllerDelegate {
    
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
