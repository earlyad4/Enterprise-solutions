import Foundation
import CoreData

// Ideally, we would generate these files, but for this scaffold we write them manually.
// This class matches the entity description in Persistence.swift

@objc(Customer)
public class Customer: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var email: String?
    @NSManaged public var lifetimeValue: Double
    @NSManaged public var lifecycleStage: String
    @NSManaged public var contracts: Set<Contract>?
}

// Extension to help with creating new instances easier
extension Customer {
    public static func fetchRequest() -> NSFetchRequest<Customer> {
        return NSFetchRequest<Customer>(entityName: "Customer")
    }
}
