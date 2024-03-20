import Foundation
import CoreData


extension Capture {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Capture> {
        return NSFetchRequest<Capture>(entityName: "Capture")
    }

    @NSManaged public var title: String?
    @NSManaged public var id: String?
    @NSManaged public var image: Data?
    @NSManaged public var date: Date?

}

extension Capture : Identifiable {

}
