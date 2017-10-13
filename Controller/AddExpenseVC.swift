//
//  AddExpenseVC.swift
//  Expense Manager
//
//  Created by Andrei Vataselu on 10/4/17.
//  Copyright © 2017 Andrei Vataselu. All rights reserved.
//

import UIKit

class AddExpenseVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userBudgetLabel: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    var initialConstraints = [NSLayoutConstraint]()
    @IBOutlet weak var sumField: UITextField!
    
    @IBOutlet weak var descriptionField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        self.sumField.delegate = self
        
        if userMoney.count > 0 {
            userBudgetLabel.text = replaceLabel(number: userMoney[userMoney.count - 1].userMoney)
        }
        
        addBtn.translatesAutoresizingMaskIntoConstraints = true
        addBtn.bindToKeyboard()
        
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(dismissViewController))
        swipeRecognizer.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRecognizer)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        print("SENDER: add expense")
        dismissViewController()
    }
    
    @IBAction func addBtnPressed(_ sender: Any) {
        var descriptionCheck = descriptionField.text!
        if descriptionCheck == "" {
            descriptionCheck = "Plata noua"
        }
        
        
        if sumField.text == "" {
            sumInvalidAlert()
        } else {
            userMoney[userMoney.count-1].userMoney -= (sumField.text! as NSString).doubleValue
            self.saveMoney(userMoney: userMoney[userMoney.count-1].userMoney, completion: { (complete) in
            })
            self.save(sumText: sumField.text!, dataDescription: descriptionCheck, dataColor: red){ complete in
            if complete {
                dismiss(animated: true, completion: nil)
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
