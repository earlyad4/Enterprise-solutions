import Foundation
import CoreData

@objc(LedgerEntry)
public class LedgerEntry: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var entryDate: Date
    @NSManaged public var userDescription: String // 'description' is a reserved property
    @NSManaged public var accountCode: String // e.g. "1000-CASH"
    @NSManaged public var debitAmount: Double
    @NSManaged public var creditAmount: Double
}

extension LedgerEntry {
    public static func fetchRequest() -> NSFetchRequest<LedgerEntry> {
        return NSFetchRequest<LedgerEntry>(entityName: "LedgerEntry")
    }
}
