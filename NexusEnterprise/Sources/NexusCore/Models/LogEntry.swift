import Foundation
import CoreData

@objc(LogEntry)
public class LogEntry: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var timestamp: Date
    @NSManaged public var content: String
    @NSManaged public var sentiment: String?
    @NSManaged public var tags: String? // Comma separated for now
    
    // In future: relationship to AI Summary Artifact
}

extension LogEntry {
    public static func fetchRequest() -> NSFetchRequest<LogEntry> {
        return NSFetchRequest<LogEntry>(entityName: "LogEntry")
    }
}
