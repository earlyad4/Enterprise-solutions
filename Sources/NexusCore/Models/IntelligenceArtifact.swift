import Foundation
import CoreData

@objc(IntelligenceArtifact)
public class IntelligenceArtifact: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var type: String // "Summary", "RiskFlag", "Opportunity"
    @NSManaged public var content: String // JSON or Text
    @NSManaged public var createdAt: Date
    
    @NSManaged public var document: Document? 
}

extension IntelligenceArtifact {
    public static func fetchRequest() -> NSFetchRequest<IntelligenceArtifact> {
        return NSFetchRequest<IntelligenceArtifact>(entityName: "IntelligenceArtifact")
    }
}
