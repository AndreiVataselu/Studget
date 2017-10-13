//
//  ExpenseCell.swift
//  Cheltuieli
//
//  Created by Andrei Vataselu on 10/3/17.
//  Copyright © 2017 Andrei Vataselu. All rights reserved.
//

import UIKit

class ExpenseCell: UITableViewCell {

    @IBOutlet weak var expenseDescription: UILabel!
    
    @IBOutlet weak var expenseSum: UILabel!
    
    func configureCell(budget: Budget){
        self.expenseDescription.text = budget.dataDescription
        self.expenseSum.text = budget.dataSum
        self.expenseSum.textColor = budget.dataColor as! UIColor
    }
    
    
}
