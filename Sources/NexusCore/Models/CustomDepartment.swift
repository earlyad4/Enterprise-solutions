import Foundation
import CoreData

@objc(CustomDepartment)
public class CustomDepartment: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var iconName: String
    @NSManaged public var createdAt: Date
}

extension CustomDepartment {
    public static func fetchRequest() -> NSFetchRequest<CustomDepartment> {
        return NSFetchRequest<CustomDepartment>(entityName: "CustomDepartment")
    }
}
