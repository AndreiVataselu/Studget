//
//  Categories+CoreDataProperties.swift
//  
//
//  Created by Andrei Vataselu on 11/14/17.
//
//

import Foundation
import CoreData


extension Categories {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Categories> {
        return NSFetchRequest<Categories>(entityName: "Categories")
    }

    @NSManaged public var categoryName: String?
    @NSManaged public var expense: NSSet?

}

// MARK: Generated accessors for expense
extension Categories {

    @objc(addExpenseObject:)
    @NSManaged public func addToExpense(_ value: Budget)

    @objc(removeExpenseObject:)
    @NSManaged public func removeFromExpense(_ value: Budget)

    @objc(addExpense:)
    @NSManaged public func addToExpense(_ values: NSSet)

    @objc(removeExpense:)
    @NSManaged public func removeFromExpense(_ values: NSSet)

}
