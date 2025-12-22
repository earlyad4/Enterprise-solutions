import Foundation
import CoreData

@objc(Document)
public class Document: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var filename: String
    @NSManaged public var contentType: String // e.g., "application/pdf"
    @NSManaged public var rawContent: String? // Extracted text
    @NSManaged public var ingestedAt: Date
    @NSManaged public var department: String? // "Finance", "Legal", etc.
}

extension Document {
    public static func fetchRequest() -> NSFetchRequest<Document> {
        return NSFetchRequest<Document>(entityName: "Document")
    }
}
