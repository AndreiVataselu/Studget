//
//  StringExt.swift
//  Expense Manager
//
//  Created by Andrei Vataselu on 10/12/17.
//  Copyright © 2017 Andrei Vataselu. All rights reserved.
//

import Foundation

extension String {
    var floatValue: Float {
        let nf = NumberFormatter()
        nf.decimalSeparator = "."
        if let result = nf.number(from: self) {
            return result.floatValue
        } else {
            nf.decimalSeparator = ","
            if let result = nf.number(from: self) {
                return result.floatValue
            }
        }
        return 0
    }
    
    var doubleValue:Double {
        let nf = NumberFormatter()
        nf.decimalSeparator = "."
        if let result = nf.number(from: self) {
            return result.doubleValue
        } else {
            nf.decimalSeparator = ","
            if let result = nf.number(from: self) {
                return result.doubleValue
            }
        }
        return 0
}
    
    private static let decimalFormatter:NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        return formatter
    }()
    
    private var decimalSeparator:String{
        return String.decimalFormatter.decimalSeparator ?? "."
    }
    
    func isValidDecimal(maximumFractionDigits:Int)->Bool{
        
        guard self.isEmpty == false else {
            return true
        }
        
        // Check if valid decimal
        if let _ = String.decimalFormatter.number(from: self){
            
            // Get fraction digits part using separator
            let numberComponents = self.components(separatedBy: decimalSeparator)
            let fractionDigits = numberComponents.count == 2 ? numberComponents.last ?? "" : ""
            return fractionDigits.characters.count <= maximumFractionDigits
        }
        
        return false
    }
}
