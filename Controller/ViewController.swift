//
//  ViewController.swift
//  Expense Manager
//
//  Created by Andrei Vataselu on 10/3/17.
//  Copyright © 2017 Andrei Vataselu. All rights reserved.
//

import UIKit
import SideMenu
import CoreData
import SwipeCellKit
import JTAppleCalendar

let green = UIColor(red:0.00, green:0.62, blue:0.45, alpha:1.0)
let red = UIColor(red:0.95, green:0.34, blue:0.34, alpha:1.0)
let appDelegate = UIApplication.shared.delegate as? AppDelegate
var userMoney : [UserMoney] = []
var managedObjectContext: NSManagedObjectContext? = appDelegate?.persistentContainer.viewContext
var budgetDeleted : Bool = false


class ViewController: UIViewController, NSFetchedResultsControllerDelegate {

    
    @IBOutlet weak var sumTextField: UITextField!
    @IBOutlet weak var userBudgetLabel: UILabel!
    @IBOutlet var tap: UITapGestureRecognizer!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var moreBtn: UIButton!
    
    func userBudgetCount(_ section: Int) -> Int{
        return fetchedResultsController.sections![section].numberOfObjects

    }
    
    func getUserBudgetAtIndexPath(indexPath : IndexPath) -> Budget {
        return fetchedResultsController.object(at: indexPath) as Budget
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        
        fetchCoreDataObject()
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        fetchCoreDataObject()
    }
    
    func fetchCoreDataObject() {
        print("FRC COUNT: \((fetchedResultsController.fetchedObjects?.count)!)")
        self.fetch { (complete) in
            if complete {
                if ((fetchedResultsController.fetchedObjects?.count)! > 0) {
                    userBudgetLabel.text = replaceLabel(number: userMoney[userMoney.count - 1].userMoney)
                    tableView.isHidden = false
                    plusButton.isHidden = false
                    moreBtn.isHidden = false
                    tableView.reloadData()
                } else {
                    tableView.isHidden = true
                    userBudgetLabel.text = "Bugetul tau"
                    plusButton.isHidden = true
                    moreBtn.isHidden = true
                }
            }
        }
    }
    
    
    var fetchedResultsController: NSFetchedResultsController<Budget> {
        if budgetDeleted == true {
            _fetchedResultsController = nil
            budgetDeleted = false
        }
        
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest<Budget>(entityName: "Budget")
        
        // Set the batch size to a suitable number.
//        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "dateSubmitted" , ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
    
    
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath: "dateSection", cacheName: nil)
    
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()

        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController<Budget>? = nil
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        tableView.reloadData()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func initialAddButtonPressed(_ sender: Any) {
        if sumTextField.text != "" {
            self.saveMoney(userMoney: (sumTextField.text! as NSString).doubleValue, completion: { (complete) in
                
            })
            self.save(sumText: sumTextField.text! , dataDescription: "Buget initial", dataColor: green) {
                complete in
                if complete {
                    tableView.isHidden = false
                }
            }
            userBudgetLabel.text = "\(sumTextField.text!) RON"
            self.fetchCoreDataObject()
            tableView.reloadData()
        } else {
            sumInvalidAlert()
        }
        self.dismissKeyboard()
        sumTextField.text = ""
    }
    @IBAction func plusButtonPressed(_ sender: Any) {
        
        let plusController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let addBudgetAction = UIAlertAction(title: "Adauga buget", style: .default) {
            (action) -> Void in

            guard let createAddBudgetVC = self.storyboard?.instantiateViewController(withIdentifier: "AddBudgetVC") else { return }
            self.presentViewController(createAddBudgetVC)
        }
        
        let addExpenseAction = UIAlertAction(title: "Adauga plata", style: .default) {
            (action) -> Void in

            guard let createAddExpenseVC = self.storyboard?.instantiateViewController(withIdentifier: "AddExpenseVC") else { return }
            self.presentViewController(createAddExpenseVC)
            
        }
        
        let cancelAction = UIAlertAction(title: "Anuleaza", style: .cancel, handler: nil)
        
        plusController.addAction(addBudgetAction)
        plusController.addAction(addExpenseAction)
        plusController.addAction(cancelAction)
        
        present(plusController, animated: true, completion: nil)
        
    }
  
    @IBAction func moreButtonPressed(_ sender: Any) {

    }
    
    
}

extension ViewController {
    func fetch(completion: (_ complete: Bool) -> ()){

        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        
        let fetchMoneyRequest = NSFetchRequest<UserMoney>(entityName: "UserMoney")
        
        do{
            userMoney = try managedContext.fetch(fetchMoneyRequest)
            print("success")
            completion(true)
        } catch {
            debugPrint("Could not fetch \(error.localizedDescription)")
            completion(false)
        }
}
   

    func removeCell(atIndexPath indexPath: IndexPath){
        let cell = getUserBudgetAtIndexPath(indexPath: indexPath)
        managedObjectContext?.delete(cell)
        
        do{
            try managedObjectContext?.save()
        } catch {}
        
    }
    
    func cancelCell(color: UIColor, atIndexPath indexPath: IndexPath){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        
        if color.description == green.description {
            // scade buget
            
            userMoney[userMoney.count - 1].userMoney -= (getUserBudgetAtIndexPath(indexPath: indexPath).dataSum! as NSString).doubleValue

        } else {

            
            userMoney[userMoney.count - 1].userMoney += (getUserBudgetAtIndexPath(indexPath: indexPath).dataSum! as NSString).doubleValue
        }
        
        do {
            try managedContext.save()
        } catch {
            print("cancelCell Managed Context Saving ERROR: \(error.localizedDescription)")
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource,SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
      guard orientation == .right else {
        let cancelAction = SwipeAction(style: .default, title: "Anuleaza"){
            (action, indexPath)
            in
            
            self.cancelCell(color: self.getUserBudgetAtIndexPath(indexPath: indexPath).dataColor as! UIColor, atIndexPath: indexPath)
            self.removeCell(atIndexPath: indexPath)
            self.fetchCoreDataObject()
        }
            cancelAction.backgroundColor = UIColor(red:0.16, green:0.63, blue:0.74, alpha:1.0)
            return [cancelAction]
        }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Sterge") { (action, indexPath) in
            self.removeCell(atIndexPath: indexPath)
            self.fetchCoreDataObject()

        }
        deleteAction.backgroundColor = red
        
        return [deleteAction]
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
        return sections.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "expenseCell") as? ExpenseCell else { return UITableViewCell() }
        print("indexPathRow: \(indexPath.row) | indexPathSection: \(indexPath.section)")
        let budget = fetchedResultsController.object(at: indexPath) as Budget
        cell.delegate = self
        cell.configureCell(budget: budget)
      
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       guard let sections = fetchedResultsController.sections else {
            return 0
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController.sections {
            let currentSections = sections[section]
            return currentSections.name
        }
        return nil
    }
    

}
