import Foundation
import CoreData

public class CrossFunctionGraph {
    
    public init() {}
    
    /// Creates a directional link between two entities.
    public func link(source: UUID, target: UUID, type: String, weight: Float = 1.0, in context: NSManagedObjectContext) throws {
        let link = CrossLink(context: context)
        link.id = UUID()
        link.sourceID = source
        link.targetID = target
        link.relationshipType = type
        link.weight = weight
        link.createdAt = Date()
        
        try context.save()
    }
    
    /// Finds all entities linked FROM a source.
    public func links(for source: UUID, in context: NSManagedObjectContext) -> [CrossLink] {
        let req = NSFetchRequest<CrossLink>(entityName: "CrossLink")
        req.predicate = NSPredicate(format: "sourceID == %@", source as CVarArg)
        return (try? context.fetch(req)) ?? []
    }
    
    /// Finds all entities linked TO a target.
    public func links(to target: UUID, in context: NSManagedObjectContext) -> [CrossLink] {
        let req = NSFetchRequest<CrossLink>(entityName: "CrossLink")
        req.predicate = NSPredicate(format: "targetID == %@", target as CVarArg)
        return (try? context.fetch(req)) ?? []
    }
}
