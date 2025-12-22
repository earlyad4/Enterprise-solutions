import Foundation
import CoreData

// The Context Bridge connects business entities to the Intelligence Graph
public class ContextBridge {
    public static let shared = ContextBridge()
    private let graph = CrossFunctionGraph()
    
    public func context(for entityID: UUID, in context: NSManagedObjectContext) -> [String] {
        // 1. Get direct links
        let links = graph.links(for: entityID, in: context)
        
        // 2. Resolve targets
        var contextItems: [String] = []
        
        for link in links {
            let targetID = link.targetID
            // In a real system, we would fetch the entity and get a summary.
            // Here we just return the ID and relation type.
            contextItems.append("Linked to \(targetID) via \(link.relationshipType)")
        }
        
        if contextItems.isEmpty {
            contextItems.append("No linked intelligence found.")
        }
        
        return contextItems
    }
    
    public func register(entity: NSManagedObject, relatedTo relatedID: UUID? = nil) {
        // When a new entity is created, we might want to auto-link it
        // implementation pending
    }
}
