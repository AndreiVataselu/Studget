//
//  UIViewControllerExt.swift
//  Expense Manager
//
//  Created by Andrei Vataselu on 10/4/17.
//  Copyright © 2017 Andrei Vataselu. All rights reserved.
//

import UIKit

@objc extension UIViewController {
    
    func presentViewController(_ viewControllerToPresent: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromRight
        self.view.window?.layer.add(transition, forKey: kCATransition)
        
        present(viewControllerToPresent, animated: false, completion: nil)
    }
    
    func dismissViewController() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromLeft
        self.view.window?.layer.add(transition, forKey: kCATransition)

        dismiss(animated: false, completion: nil)

    }
    
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    func save(sumText: String, dataDescription: String, dataColor: UIColor, completion: (_ finished: Bool) -> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        let budget = Budget(context: managedContext)
        
        budget.dataSum = sumText
        budget.dataDescription = dataDescription
        budget.dataColor = dataColor
        
        do{
            try managedContext.save()
            print("Succesfully saved data")
            completion(true)
        } catch {
            debugPrint("Could not save \(error.localizedDescription)")
            completion(false)
        }
    }
    
    func saveMoney(userMoney: Double, completion: (_ finished: Bool) -> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        let money = UserMoney(context: managedContext)
        
        money.userMoney = userMoney
        
        do {
            try managedContext.save()
            print("saved money")
            completion(true)
        } catch {
            print("could not save \(error.localizedDescription)")
            completion(false)
        }
    }
    
    func sumInvalidAlert() {
        let sumAlert = UIAlertController(title: "Suma invalida", message: nil, preferredStyle: .alert)
        sumAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(sumAlert, animated: true, completion: nil)
        }
    
    func replaceLabel (number: Double) -> String  {
        if number.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(userMoney[userMoney.count - 1].userMoney)) RON"
        } else {
            return "\(userMoney[userMoney.count - 1].userMoney) RON"
        }
    }
}
    


