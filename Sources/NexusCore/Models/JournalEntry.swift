import Foundation
import CoreData

@objc(JournalEntry)
public class JournalEntry: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var content: String?
    @NSManaged public var createdAt: Date
}

extension JournalEntry {
    public static func fetchRequest() -> NSFetchRequest<JournalEntry> {
        return NSFetchRequest<JournalEntry>(entityName: "JournalEntry")
    }
}
