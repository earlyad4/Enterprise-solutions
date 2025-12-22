import Foundation
import CoreData

@objc(Project)
public class Project: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var status: String
    @NSManaged public var projectDescription: String?
    @NSManaged public var deadline: Date?
}

extension Project {
    public static func fetchRequest() -> NSFetchRequest<Project> {
        return NSFetchRequest<Project>(entityName: "Project")
    }
}
