import Foundation
import CoreData

@objc(Campaign)
public class Campaign: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var type: String // "Email", "Social", "Print"
    @NSManaged public var startDate: Date
    @NSManaged public var budget: Double
    @NSManaged public var status: String // "Planning", "Active", "Completed"
    
     @NSManaged public var segments: Set<Segment>?
}

extension Campaign {
    public static func fetchRequest() -> NSFetchRequest<Campaign> {
        return NSFetchRequest<Campaign>(entityName: "Campaign")
    }
}
