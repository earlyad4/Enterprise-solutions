import Foundation
import CoreData

@objc(Contract)
public class Contract: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var value: Double
    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date
    @NSManaged public var status: String // "Active", "Draft", "Expired"
    
    @NSManaged public var customer: Customer?
}

extension Contract {
    public static func fetchRequest() -> NSFetchRequest<Contract> {
        return NSFetchRequest<Contract>(entityName: "Contract")
    }
}
