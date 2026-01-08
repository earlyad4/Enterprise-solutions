import Foundation
import CoreData

@objc(Product)
public class Product: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var productDescription: String?
    @NSManaged public var price: Double
    @NSManaged public var positioning: String?
}

extension Product {
    public static func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }
}
