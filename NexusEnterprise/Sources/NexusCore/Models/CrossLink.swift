import Foundation
import CoreData

@objc(CrossLink)
public class CrossLink: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var sourceID: UUID
    @NSManaged public var targetID: UUID
    @NSManaged public var relationshipType: String // "owns", "references", "blocks"
    @NSManaged public var weight: Float
    @NSManaged public var createdAt: Date
}

extension CrossLink {
    public static func fetchRequest() -> NSFetchRequest<CrossLink> {
        return NSFetchRequest<CrossLink>(entityName: "CrossLink")
    }
}
