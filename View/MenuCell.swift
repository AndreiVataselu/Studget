//
//  MenuCell.swift
//  Expense Manager
//
//  Created by Andrei Vataselu on 10/14/17.
//  Copyright © 2017 Andrei Vataselu. All rights reserved.
//

import Foundation
import UIKit

class MenuCell : UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.frame = CGRect(x: 10, y: 15, width: 25, height: 25)
        self.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        self.textLabel?.frame = CGRect(x: 40, y: 10, width: self.frame.width - 35, height: 35)
    }
    
}
