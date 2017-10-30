//
//  PeriodExpenses.swift
//  Expense Manager
//
//  Created by Andrei Vataselu on 10/29/17.
//  Copyright © 2017 Andrei Vataselu. All rights reserved.
//

import UIKit
import CoreData

class PeriodExpenses: UIViewController, NSFetchedResultsControllerDelegate{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var periodLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        periodLabel.text = periodString
        
        // Do any additional setup after loading the view.
    }

        
        var fetchedResultsController: NSFetchedResultsController<Budget> {
             let predicate = NSPredicate(format: "(dateSubmitted >= %@) AND (dateSubmitted <= %@)", date1 as NSDate, date2 as NSDate)
            
            let fetchRequest = NSFetchRequest<Budget>(entityName: "Budget")
            
            // Set the batch size to a suitable number.
            fetchRequest.fetchBatchSize = 20
            
            // Edit the sort key as appropriate.
            let sortDescriptor = NSSortDescriptor(key: "dateSubmitted" , ascending: false)
            
            fetchRequest.sortDescriptors = [sortDescriptor]
            fetchRequest.predicate = predicate
            
            // Edit the section name key path and cache name if appropriate.
            // nil for section name key path means "no sections".
            
            
            let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath: "dateSection", cacheName: "cacheRequest")
            
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismissViewController()
    }
}

extension PeriodExpenses : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController.sections![section].name
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "periodCell") as! ExpenseCell
        let budget = fetchedResultsController.object(at: indexPath)
        cell.configureCell(budget: budget)
        print("CELL DESC: \((cell.expenseDescription)!) | DATE: \((budget.dateSubmitted)!)")
        
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return (fetchedResultsController.sections?.count)!
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}

