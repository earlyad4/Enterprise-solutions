import Foundation
import CoreData

public class DocumentIntakeEngine {
    
    public init() {}
    
    /// Ingests a file from a URL, creates a Document entity, and returns it.
    /// In a real app, this would copy the file to a secure sandbox container.
    public func ingestFile(from url: URL, into context: NSManagedObjectContext) throws -> Document {
        let doc = Document(context: context)
        doc.id = UUID()
        doc.filename = url.lastPathComponent
        doc.ingestedAt = Date()
        // Naive classification based on extension
        let ext = url.pathExtension.lowercased()
        switch ext {
        case "pdf": doc.contentType = "application/pdf"
        case "txt": doc.contentType = "text/plain"
        default: doc.contentType = "application/octet-stream"
        }
        
        doc.department = "General" // Default, can be updated by pipeline
        
        // Simulating text extraction for text files
        if ext == "txt" {
            doc.rawContent = try? String(contentsOf: url)
        }
        
        // Save
        try context.save()
        return doc
    }
}
