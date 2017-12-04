//
//  UIViewControllerExt.swift
//  Expense Manager
//
//  Created by Andrei Vataselu on 10/4/17.
//  Copyright © 2017 Andrei Vataselu. All rights reserved.
//

import CoreData
import UIKit

@objc extension UIViewController {
    
    func fetchCategories (completion: (_ complete: Bool) -> ()) {
        
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        
        let fetchCategoryRequest = NSFetchRequest<Categories>(entityName: "Categories")
        
        do {
            userCategories = try managedContext.fetch(fetchCategoryRequest)
            completion(true)
        } catch {
            completion(false)
        }
        
    }
    
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
        tap.cancelsTouchesInView = false
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    func saveCategory(category: String, completion : (_ finished: Bool) -> ()) {
        let categ = NSEntityDescription.insertNewObject(forEntityName: "Categories", into: managedObjectContext!) as! Categories
        
        categ.categoryName = category
        
        do {
            try managedObjectContext?.save()
            completion(true)
        } catch {
            completion(false)
        }
    }
    
    func save(sumText: String, dataDescription: String, dataColor: UIColor, category: Categories?, type: String, completion: (_ finished: Bool) -> ()) {
        let budget = NSEntityDescription.insertNewObject(forEntityName: "Budget", into: managedObjectContext!) as! Budget
        
        budget.dataSum = sumText
        budget.dataDescription = dataDescription
        budget.dataColor = dataColor
        budget.dateSubmitted = Date()
        budget.dateSection = formatDate(date: Date())
        budget.type = type
        
        if let cat = category {
            budget.category = cat
        }

        
        do{
            try managedObjectContext?.save()
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
        
        let titleAlert = NSLocalizedString("invalidSum", comment: "")
        
        let sumAlert = UIAlertController(title: titleAlert, message: nil, preferredStyle: .alert)
        sumAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(sumAlert, animated: true, completion: nil)
        }
    
    // MARK:- Localized here
    
    func replaceLabel (number: Double) -> String  {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value:number))
        
        return ("\(formattedNumber!) \(Locale.current.currencySymbol!)")
    }
    
    func formatDate (date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Calendar.current.locale
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        return dateFormatter.string(from: date)
    }
    
    func showDetailedExpense(object: Budget){        
        var catString = NSLocalizedString("noCategory", comment: "")
        
        detailData = []
        
        if let categoryExists = object.category {
            catString = categoryExists.categoryName!
        }
        
        detailData.append(object.dataSum!)
        detailData.append(object.dataDescription!)
        detailData.append(catString)
        detailData.append(object.dateSection!)
        detailData.append(object.type!)
        
        let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailVC")
        navigationController?.pushViewController(detailVC!, animated: true)
    }
}
    


