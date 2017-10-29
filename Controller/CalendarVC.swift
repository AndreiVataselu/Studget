//
//  CalendarVC.swift
//  Expense Manager
//
//  Created by Andrei Vataselu on 10/23/17.
//  Copyright © 2017 Andrei Vataselu. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarVC: UIViewController {

    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthLabel : UILabel!
    @IBOutlet weak var yearLabel : UILabel!
    @IBOutlet weak var headerLabel : UILabel!
    @IBOutlet weak var okButtonOutlet : UIButton!
    @IBOutlet weak var quickShowView : QuickShowView!
    
    let formatter = DateFormatter()
    var firstDate : Date?
    var endDate : Date?
    var dateToDeselect : Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendarView()
        let tapMonth = UITapGestureRecognizer(target: self, action: #selector(monthTap))
        let tapYear = UITapGestureRecognizer(target: self, action: #selector(yearTap))
        
        quickShowView.alpha = 0
        
        monthLabel.addGestureRecognizer(tapMonth)
        yearLabel.addGestureRecognizer(tapYear)
        // Do any additional setup after loading the view.
    }

    @objc func monthTap (gestureRecognizer: UITapGestureRecognizer){
        print("month")
    }
    
    @objc func yearTap (gestureRecognizer: UITapGestureRecognizer){
        print("year")
    }
    
    func setupCalendarView(){
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        calendarView.allowsMultipleSelection = true
        calendarView.isRangeSelectionUsed = true
        
        calendarView.scrollToDate(Date(), animateScroll: false)

        
        calendarView.visibleDates { (visibleDates) in
            self.setupCalendarViews(from: visibleDates)
       
        }
    }
    
    
    func handleCellSelected(view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? CalendarCell else {return}
        if validCell.isSelected {
            validCell.selectedView.isHidden = false
        } else {
            validCell.selectedView.isHidden = true
        }
        
        
    }
    
    func handleCellTextColor(view: JTAppleCell?, cellState: CellState){
        guard let validCell = view as? CalendarCell else {return}
        if validCell.isSelected {
            validCell.dateLabel.textColor = UIColor.white
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                validCell.dateLabel.textColor = UIColor.black
            } else {
                validCell.dateLabel.textColor = UIColor.lightGray
            }
        }
    }
    
    func setupCalendarViews(from visibleDates: DateSegmentInfo){
        let date = visibleDates.monthDates.first!.date
        self.formatter.dateFormat = "MMMM"
        self.monthLabel.text = self.formatter.string(from: date)
        
        self.formatter.dateFormat = "yyyy"
        self.yearLabel.text = self.formatter.string(from: date)
    }

    func animateQuickShow() {
        UIView.animate(withDuration: 0.5, animations: {
            self.quickShowView.alpha = 1.0
            self.quickShowView.frame.origin.y = 130
        })
    }
    
    func dismissQuickShow () {
        UIView.animate(withDuration: 0.2) {
            self.quickShowView.alpha = 0

        }
    }
    
    func dismissQuickShowLabels () {
        UIView.animate(withDuration: 0.5) {
          self.quickShowView.budgetLabel.frame.origin.x -=  400
           self.quickShowView.expenseLabel.frame.origin.x -= 400
           self.quickShowView.totalBudget.frame.origin.x -= 400
            self.quickShowView.totalExpense.frame.origin.x -= 400
        }
    }
    
    func showQuickShowLabels () {
        self.quickShowView.budgetLabel.frame.origin.x +=  400
        self.quickShowView.expenseLabel.frame.origin.x += 400
        self.quickShowView.totalBudget.frame.origin.x += 400
        self.quickShowView.totalExpense.frame.origin.x += 400
    }
    
    func populateData(firstIndex: Int, lastIndex : Int?=nil){
        var budgetTotal : Double = 0
        var expenseTotal : Double = 0
        
        if let endIndex = lastIndex {
        for i in endIndex...firstIndex {
            for j in 0..<(_fetchedResultsController?.sections![i].numberOfObjects)! {
                let indexPath = IndexPath(row: j, section: i)
                let object = (_fetchedResultsController?.object(at: indexPath))!
                if object.dataColor?.description == red.description {
                    expenseTotal += (object.dataSum! as NSString).doubleValue
                } else if object.dataColor?.description == green.description {
                    budgetTotal += (object.dataSum! as NSString).doubleValue
                }
            }
        }
        } else {
            for i in 0..<(_fetchedResultsController?.sections![firstIndex].numberOfObjects)! {
                let indexPath = IndexPath(row: i, section: firstIndex)
                let object = (_fetchedResultsController?.object(at: indexPath))!
                if object.dataColor?.description == red.description {
                    expenseTotal += (object.dataSum! as NSString).doubleValue
                } else if object.dataColor?.description == green.description {
                    budgetTotal += (object.dataSum! as NSString).doubleValue
                }
            }
        }
           if quickShowView.alpha == 0 {
            quickShowView.totalBudget.text = replaceLabel(number: budgetTotal)
            quickShowView.totalExpense.text = replaceLabel(number: expenseTotal)

            animateQuickShow()
        } else {
            dismissQuickShowLabels()
            quickShowView.totalBudget.text = replaceLabel(number: budgetTotal)
            quickShowView.totalExpense.text = replaceLabel(number: expenseTotal)
            showQuickShowLabels()
        }
    }
    
    func getSectionIndex (name: String) -> Int? {
        for i in 0..<(_fetchedResultsController?.sections?.count)! {
            if _fetchedResultsController?.sections![i].name == name {
                return i
            }
        }
        return nil
    }

    
    func getFirstIndex (firstDate: String, endDate: String) -> Int? {
        var unwrapDate = formatter.date(from: firstDate)
        while unwrapDate! < formatter.date(from: endDate)! {
            if let firstIndex = getSectionIndex(name: formatter.string(from: unwrapDate!)) {
                print("firstIndex: \(formatter.string(from: unwrapDate!))")
                return firstIndex
            }
            unwrapDate = Calendar.current.date(byAdding: .day, value: 1, to: unwrapDate!)
        }
        return nil
    }
    
    func getLastIndex (firstDate: String, endDate: String) -> Int? {
        
        var unwrapDate = formatter.date(from: endDate)
        while (formatter.date(from: firstDate))! < unwrapDate! {
            if let lastIndex = getSectionIndex(name: formatter.string(from: unwrapDate!)) {
                print("lastIndex: \(formatter.string(from: unwrapDate!))")
                return lastIndex
            }
            
            unwrapDate = Calendar.current.date(byAdding: .day, value: -1, to: unwrapDate!)
            
        }
        return nil
    }
    
    // - MARK: Quick Budget
    func showQuickInfoAboutBudget (firstDate:String, endDate:String?=nil) {
        if let unwrapEndDate = endDate {
            if let firstIndex = getFirstIndex(firstDate: firstDate, endDate: unwrapEndDate) {
                if let lastIndex = getLastIndex(firstDate: firstDate, endDate: unwrapEndDate) {
                    populateData(firstIndex: firstIndex, lastIndex: lastIndex)
                } else {
                    populateData(firstIndex: firstIndex)
                }
            } else if let lastIndex = getLastIndex(firstDate: firstDate, endDate: unwrapEndDate) {
                populateData(firstIndex: lastIndex)
            }
            
        } else {
            if let index = getSectionIndex(name: firstDate) {
                quickShowView.alpha = 0
                populateData(firstIndex: index)
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        print("SENDER: CalendarVC")
        dismissViewController()
    }
    
}

extension CalendarVC: JTAppleCalendarViewDataSource {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {

        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Locale(identifier: "ro")
        
        let startDate = formatter.date(from: "2017 01 01")
        let endDate = formatter.date(from: "2099 12 31")
        let parameters = ConfigurationParameters(startDate: startDate!, endDate: endDate!, firstDayOfWeek: .monday)
        return parameters
    }
    
}

extension CalendarVC: JTAppleCalendarViewDelegate {
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        
        cell.dateLabel.text = cellState.text
        
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        
        return cell
    }
    
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {

        
        if firstDate != nil {
            if date < firstDate! {
                 calendarView.selectDates(from: date, to: firstDate!, triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
                endDate = firstDate
                dateToDeselect = date
                formatter.dateFormat = "dd.MM"
                headerLabel.text = "\(formatter.string(from: date)) - \(formatter.string(from: firstDate!))"
                okButtonOutlet.isHidden = false
                
                formatter.dateFormat = "dd.MM.yyyy"
                showQuickInfoAboutBudget(firstDate: formatter.string(from: date), endDate: formatter.string(from: firstDate!) )
                
                firstDate = nil
                
            } else {
            calendarView.selectDates(from: firstDate!, to: date, triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
                
                formatter.dateFormat = "dd.MM"
                headerLabel.text = "\(formatter.string(from: firstDate!)) - \(formatter.string(from: date)) "
                endDate = date
                dateToDeselect = firstDate
                
                formatter.dateFormat = "dd.MM.yyyy"
                showQuickInfoAboutBudget(firstDate: formatter.string(from: firstDate!), endDate: formatter.string(from: date))
                
                firstDate = nil
                okButtonOutlet.isHidden = false

            }
         
        } else {
            if endDate != nil {
            calendarView.deselectDates(from: dateToDeselect!, to: endDate!, triggerSelectionDelegate: false)
                endDate = nil
                dismissQuickShow()
                headerLabel.text = "Selecteaza o perioada"
                okButtonOutlet.isHidden = true
            }
            
            firstDate = date
            formatter.dateFormat = "dd.MM.yyyy"
            headerLabel.text = "\(formatter.string(from: date))"
            okButtonOutlet.isHidden = false
            
            showQuickInfoAboutBudget(firstDate: formatter.string(from: date))
        }
        
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)

    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        if endDate != nil {
            calendarView.deselectDates(from: dateToDeselect!, to: endDate!, triggerSelectionDelegate: false)
            dismissQuickShow()
            endDate = nil
            firstDate = nil
            headerLabel.text = "Selecteaza o perioada"
            okButtonOutlet.isHidden = true
        } else {
            firstDate = nil
            dismissQuickShow()
        }
        
        headerLabel.text = "Selecteaza o perioada"
        okButtonOutlet.isHidden = true

        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
            self.setupCalendarViews(from: visibleDates)
        
    }
}
