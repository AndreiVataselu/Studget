//
//  MenuVC.swift
//  Expense Manager
//
//  Created by Andrei Vataselu on 10/13/17.
//  Copyright © 2017 Andrei Vataselu. All rights reserved.
//
import Foundation
import UIKit
import CoreData
import JTAppleCalendar


class MenuVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            deleteBudget()
            tableView.deselectRow(at: indexPath, animated: false)
        case 1:
           guard let showCalendar =  self.storyboard?.instantiateViewController(withIdentifier: "CalendarVC") else { return }
           if let navigator = self.navigationController {
            navigator.pushViewController(showCalendar, animated: true)
            }
            
        case 2:
            guard let showCategoriesVC = self.storyboard?.instantiateViewController(withIdentifier: "CategoriesVC") else {return}
            if let navigator = self.navigationController {
                navigator.pushViewController(showCategoriesVC, animated: true)
            }
            
        default: print("none")
    
        }
        
    }
    
    
    //MARK:- Localized
    func deleteBudget(){
        let sureCheck = UIAlertController(title: NSLocalizedString("eraseBudgetTitle", comment: ""), message: NSLocalizedString("eraseBudgetMsg", comment: ""), preferredStyle: .alert)
        
        let noAlert = UIAlertAction(title: NSLocalizedString("noAns", comment: ""), style: .default, handler: nil)
        let yesAlert = UIAlertAction(title: NSLocalizedString("yesAns", comment: ""), style: .destructive) {
            action -> Void in
            
            guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
            
            let fetchBudget = NSFetchRequest<NSFetchRequestResult>(entityName: "Budget")
            let fetchMoney = NSFetchRequest<NSFetchRequestResult>(entityName: "UserMoney")
            let requestDeleteBudget = NSBatchDeleteRequest(fetchRequest: fetchBudget)
            let requestDeleteMoney = NSBatchDeleteRequest(fetchRequest: fetchMoney)

            
            
            do {
                try managedObjectContext?.execute(requestDeleteBudget)
                try managedContext.execute(requestDeleteMoney)
                try managedContext.save()
            } catch {
                
            }
            
            budgetDeleted = true
         
            let succesDelete = UIAlertController(title: NSLocalizedString("succesMsg", comment: ""), message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            })
            
            succesDelete.addAction(okAction)
            self.present(succesDelete, animated:true, completion: nil)
            
        }
        
        sureCheck.addAction(noAlert)
        sureCheck.addAction(yesAlert)
        
        present(sureCheck, animated: true, completion: nil)
        
    }
    
    
}

