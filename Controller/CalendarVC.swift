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
    
    let formatter = DateFormatter()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendarView()
        
        let tapMonth = UITapGestureRecognizer(target: self, action: #selector(monthTap))
        let tapYear = UITapGestureRecognizer(target: self, action: #selector(yearTap))
        
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
//        let cell = cell as! CalendarCell
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
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
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)

    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
       handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)

    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
            self.setupCalendarViews(from: visibleDates)
    }
}

