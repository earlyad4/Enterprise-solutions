import Foundation
import CoreData

@objc(Invoice)
public class Invoice: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var invoiceNumber: String
    @NSManaged public var issueDate: Date
    @NSManaged public var dueDate: Date
    @NSManaged public var totalAmount: Double
    @NSManaged public var status: String // "Draft", "Sent", "Paid"
    
    // We will define relationship to Customer in Persistence.swift
    // @NSManaged public var customer: Customer?
}

extension Invoice {
    public static func fetchRequest() -> NSFetchRequest<Invoice> {
        return NSFetchRequest<Invoice>(entityName: "Invoice")
    }
}
