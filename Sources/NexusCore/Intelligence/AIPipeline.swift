import Foundation
import CoreData

public class AIPipeline {
    public static let shared = AIPipeline()
    
    private let intakeEngine = DocumentIntakeEngine()
    
    // In a real app, this would use a model from CoreML or an API
    // For now, it orchestrates the steps: Ingest -> Classify (Stub) -> Extract (Stub)
    
    public func processDocument(url: URL, in context: NSManagedObjectContext) async throws -> Document {
        // 1. Ingest
        let document = try intakeEngine.ingestFile(from: url, into: context)
        
        // 2. Classify (Simulated)
        let classification = await classify(document.rawContent ?? "")
        document.department = classification
        
        // 3. Extract Intelligence (Simulated)
        let artifact = IntelligenceArtifact(context: context)
        artifact.id = UUID()
        artifact.createdAt = Date()
        artifact.type = "Summary"
        artifact.content = "Auto-generated summary for \(document.filename)"
        artifact.document = document
        
        try context.save()
        
        return document
    }
    
    private func classify(_ content: String) async -> String {
        // Naive keyword matching
        let lower = content.lowercased()
        if lower.contains("invoice") || lower.contains("ledger") { return "Finance" }
        if lower.contains("contract") || lower.contains("agreement") { return "CRM" }
        if lower.contains("campaign") { return "Marketing" }
        if lower.contains("research") || lower.contains("tech") { return "R&D" }
        return "General"
    }
}
