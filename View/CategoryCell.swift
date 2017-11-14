//
//  CategoryCell.swift
//  Expense Manager
//
//  Created by Andrei Vataselu on 11/14/17.
//  Copyright © 2017 Andrei Vataselu. All rights reserved.
//

import UIKit
import SwipeCellKit

class CategoryCell: SwipeTableViewCell  {

    
    @IBOutlet weak var titleLabel : UILabel!
    
    func configureCell(title: String) {
        titleLabel.text = title
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
