import Foundation
import CoreData

@objc(Segment)
public class Segment: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var criteria: String // e.g. "LTV > $1000"
    @NSManaged public var estimatedSize: Int64
    
    @NSManaged public var campaigns: Set<Campaign>?
}

extension Segment {
    public static func fetchRequest() -> NSFetchRequest<Segment> {
        return NSFetchRequest<Segment>(entityName: "Segment")
    }
}
