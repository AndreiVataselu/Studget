//
//  AddBudgetVC.swift
//  Expense Manager
//
//  Created by Andrei Vataselu on 10/4/17.
//  Copyright © 2017 Andrei Vataselu. All rights reserved.
//

import UIKit

class AddBudgetVC: UIViewController {
    
    @IBOutlet weak var userBudgetLabel: UILabel!
    @IBOutlet weak var sumText: UITextField!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var descriptionText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        
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
        print("SENDER: add budget")
        dismissViewController()
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
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
}
}
