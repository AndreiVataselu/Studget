//
//  ExpenseCell.swift
//  Cheltuieli
//
//  Created by Andrei Vataselu on 10/3/17.
//  Copyright © 2017 Andrei Vataselu. All rights reserved.
//

import UIKit
import SwipeCellKit

class ExpenseCell: SwipeTableViewCell {

    @IBOutlet weak var expenseDescription: UILabel!
    
    @IBOutlet weak var expenseSum: UILabel!
    
    func configureCell(budget: Budget){
        self.expenseDescription.text = budget.dataDescription
        self.expenseSum.text = replaceLabel(number: (budget.dataSum! as NSString).doubleValue)
        self.expenseSum.textColor = budget.dataColor as! UIColor
    }
    
    func replaceLabel (number: Double) -> String  {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value:number))
        
        return ("\(formattedNumber!) \(Locale.current.currencySymbol!)")
        
    }
    
}

