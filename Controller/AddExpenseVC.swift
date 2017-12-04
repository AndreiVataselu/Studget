//
//  AddExpenseVC.swift
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

var bindAddExpenseBtn = true

class AddExpenseVC: UIViewController, UITextFieldDelegate {
    
    var percentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition!
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    @IBOutlet weak var userBudgetLabel: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var sumField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView : UITableView!

    
    @IBOutlet weak var descriptionField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        self.sumField.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        bindAddExpenseBtn = true
        
        let tvFooter = UIView()
        tableView.tableFooterView = tvFooter
        tableView.isScrollEnabled = false

        tableView.reloadData()
        
        btc = bottomConstraint
        
        if userMoney.count > 0 {
            userBudgetLabel.text = replaceLabel(number: userMoney[userMoney.count - 1].userMoney)
        }
        
        addBtn.bindToKeyboard()

        addGesture()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if !bindAddExpenseBtn {
            print("BAEB")
        btc = bottomConstraint
        addBtn.bindToKeyboard()
        }
        tableView.reloadData()
    }
    
    func addGesture() {
        
        guard navigationController?.viewControllers.count > 1 else {
            return
        }
        
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(AddExpenseVC.handlePanGesture(_:)))
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
                isCellSelected = []
                percentDrivenInteractiveTransition.finish()
            } else {
                bindAddExpenseBtn = true
                percentDrivenInteractiveTransition.cancel()
            }
            
        case .cancelled, .failed:
            bindAddExpenseBtn = true
            percentDrivenInteractiveTransition.cancel()
            
        default:
            break
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        isCellSelected = []
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addBtnPressed(_ sender: Any) {
        var descriptionCheck = descriptionField.text!
        if descriptionCheck == "" {
            descriptionCheck = NSLocalizedString("emptyExpenseDesc", comment: "")
        }
        
        let sumFieldDecimal = sumField.text?.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil)

        
        if sumFieldDecimal == "" {
            sumInvalidAlert()
        } else {
            
            if userMoney.count == 0 {
                self.saveMoney(userMoney: (sumField.text! as NSString).doubleValue , completion: { (_) in
                    
                })
            } else {
                
            
            userMoney[userMoney.count-1].userMoney -= (sumFieldDecimal! as NSString).doubleValue
            self.saveMoney(userMoney: userMoney[userMoney.count-1].userMoney, completion: { (complete) in
            })
            }
            
            var selectedC : Categories? = nil
            for i in 0..<isCellSelected.count {
                if isCellSelected[i]{
                    selectedC = userCategories[i]
                }
            }
            
            self.save(sumText: sumFieldDecimal! , dataDescription: descriptionCheck, dataColor: red, category: selectedC, type: "expense" ){ complete in
            if complete {
                isCellSelected = []
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
}
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Get text
        let currentText = textField.text ?? ""
        let replacementText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        // Validate
        return replacementText.isValidDecimal(maximumFractionDigits: 2)
        
    }
}

extension AddExpenseVC : UINavigationControllerDelegate {
    
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

extension AddExpenseVC : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PickCategoryCell") as! PickCategoryCell
        
        var selectedCell : String = ""
        for i in 0..<isCellSelected.count {
            if isCellSelected[i]{
                selectedCell = userCategories[i].categoryName!
            }
        }
        
        if selectedCell != "" {
            cell.labelView.text = selectedCell
        } else {
        cell.labelView.text = NSLocalizedString("optionalCat", comment: "")
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        switch indexPath.row {
            
        case 0:
        
        bindAddExpenseBtn = false
        self.addBtn.removeBind()
        let selectCatVC = storyboard?.instantiateViewController(withIdentifier: "SelectCategoryVC")
        navigationController?.pushViewController(selectCatVC!, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
        
        default: break
        }
    }

}
