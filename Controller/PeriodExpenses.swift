//
//  PeriodExpenses.swift
//  Expense Manager
//
//  Created by Andrei Vataselu on 10/29/17.
//  Copyright © 2017 Andrei Vataselu. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds

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

var filteredItems = [Budget]()

class PeriodExpenses: UIViewController, NSFetchedResultsControllerDelegate, GADBannerViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet var bannerView: GADBannerView!
    @IBOutlet weak var noResultsFoundLabel : UILabel!
    
    var percentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition!
    var panGestureRecognizer: UIPanGestureRecognizer!
    var searchBar = UISearchBar()

    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        periodLabel.text = periodString
        bannerView.adSize = kGADAdSizeSmartBannerPortrait

//        bannerView.adUnitID = "ca-app-pub-3588787712275306/8074266186"
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(GADRequest())
        
        searchBar.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 45)
        searchBar.barTintColor = UIColor(red:0.54, green:0.77, blue:0.80, alpha:1.0)
        searchBar.placeholder = "Cauta cheltuieli"
        searchBar.backgroundImage = #imageLiteral(resourceName: "searchbarback")
        
        searchBar.delegate = self
        
        tableView.tableHeaderView = searchBar
        tableView.setContentOffset(CGPoint.init(x: 0, y: 44), animated: true)

        addGesture()

    }
    
    func searchBarIsEmpty() -> Bool {
        return searchBar.text?.isEmpty ?? true
    }

    
    func addGesture() {
        
        guard navigationController?.viewControllers.count > 1 else {
            return
        }
        
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(PeriodExpenses.handlePanGesture(_:)))
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
    
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        tableViewBottomConstraint.constant -= 50
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        tableViewBottomConstraint.constant = 0
    }

        
        var fetchedResultsController: NSFetchedResultsController<Budget> {
            
            _fetchedResultsController = nil
            NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: "cachePeriod")

            
             let predicate = NSPredicate(format: "(dateSubmitted >= %@) AND (dateSubmitted <= %@)", date1 as NSDate, date2 as NSDate)
            
            let fetchRequest = NSFetchRequest<Budget>(entityName: "Budget")
            
            // Set the batch size to a suitable number.
            fetchRequest.fetchBatchSize = 20
            
            // Edit the sort key as appropriate.
            let sortDescriptor = NSSortDescriptor(key: "dateSubmitted" , ascending: false)
            
            fetchRequest.predicate = predicate
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension PeriodExpenses : UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredItems = (fetchedResultsController.fetchedObjects?.filter({(budget : Budget) -> Bool in
            return (budget.dataDescription?.lowercased().contains(searchText.lowercased()))!
        }))!
        
        if filteredItems.count == 0  && searchText != "" {
            noResultsFoundLabel.isHidden = false
        } else {
            noResultsFoundLabel.isHidden = true
        }
        tableView.reloadData()
    }

    
    func isFiltering() -> Bool {
        return !searchBarIsEmpty()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering() {
            return filteredItems.count
        }
        
        return fetchedResultsController.sections![section].numberOfObjects
    }
    
    

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if isFiltering() {
            if filteredItems.count == 0 {
                return nil
            }
            return "Rezultate cautare: "
            
        } else
            if let object = fetchedResultsController.object(at: IndexPath(row: 0, section: section)) as? Budget {
            return object.dateSection
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "periodCell") as! ExpenseCell
        var budget = Budget()

        if isFiltering() {
            budget = filteredItems[indexPath.row]
         
        } else {
            budget = fetchedResultsController.object(at: indexPath)
        }
        
        cell.configureCell(budget: budget)
        cell.selectionStyle = .none
        
        return cell
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering() {
            if filteredItems.count == 0 {
                return 0
            }
            return 1
        }
        return (fetchedResultsController.sections?.count)!
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

}

extension PeriodExpenses: UINavigationControllerDelegate {
    
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

