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
import SWTableViewCell

let green = UIColor(red:0.00, green:0.62, blue:0.45, alpha:1.0)
let red = UIColor(red:0.95, green:0.34, blue:0.34, alpha:1.0)
let appDelegate = UIApplication.shared.delegate as? AppDelegate
var userBudget : [Budget] = []
var userMoney : [UserMoney] = []


class ViewController: UIViewController {

    
    @IBOutlet weak var sumTextField: UITextField!
    @IBOutlet weak var userBudgetLabel: UILabel!
    @IBOutlet var tap: UITapGestureRecognizer!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.tableFooterView = UIView()

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCoreDataObject()
        tableView.reloadData()
    }
    
    func fetchCoreDataObject() {
        self.fetch { (complete) in
            if complete {
                userBudget.reverse()
                if userBudget.count >= 1 {
                    print(userBudget.count)
                    userBudgetLabel.text = replaceLabel(number: userMoney[userMoney.count - 1].userMoney)
                    tableView.isHidden = false
                    plusButton.isHidden = false
                } else {
                    tableView.isHidden = true
                    userBudgetLabel.text = "Bugetul tau"
                    plusButton.isHidden = true
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func initialAddButtonPressed(_ sender: Any) {
        if sumTextField.text != "" {
            self.saveMoney(userMoney: (sumTextField.text! as NSString).doubleValue, completion: { (complete) in
                
            })
            self.save(sumText: sumTextField.text!, dataDescription: "Buget initial", dataColor: green) {
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
        
        let fetchRequest = NSFetchRequest<Budget>(entityName: "Budget")
        let fetchMoneyRequest = NSFetchRequest<UserMoney>(entityName: "UserMoney")
        
        do{
            userBudget = try managedContext.fetch(fetchRequest)
            userMoney = try managedContext.fetch(fetchMoneyRequest)
            print("success")
            completion(true)
            print(userBudget.count)
        } catch {
            debugPrint("Could not fetch \(error.localizedDescription)")
            completion(false)
        }
    }
    
    func removeCell(atIndexPath indexPath: IndexPath){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        managedContext.delete(userBudget[indexPath.row])
        
        
        do {
            try managedContext.save()
            debugPrint("dai ca merge")
        } catch {
            debugPrint("nu merge boss \(error.localizedDescription)")
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "expenseCell") as? ExpenseCell else { return UITableViewCell() }
        let budget = userBudget[indexPath.row]
        cell.configureCell(budget: budget)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Sterge") { (rowAction, indexPath) in
            self.removeCell(atIndexPath: indexPath)
            self.fetchCoreDataObject()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        deleteAction.backgroundColor = red
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userBudget.count
    }
}

