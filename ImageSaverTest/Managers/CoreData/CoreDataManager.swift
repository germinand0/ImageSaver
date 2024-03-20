import Foundation
import CoreData

final class CoreDataManager: Storage {
    private var context: NSManagedObjectContext = {
        persistentContainer.viewContext
    }()
    
    private static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ImageSaverTest")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func saveCapture(_ captureInfo: CoreCaptureInfo) {
        let capture = Capture(context: context)
        capture.id = captureInfo.id
        capture.image = captureInfo.imageData
        capture.date = captureInfo.date
        capture.title = captureInfo.title
        saveContext()
    }
    
    func changeCapture(_ actualCapture: CoreCaptureInfo) {
        guard let capture = getCapture(id: actualCapture.id) else { return }
        capture.title = actualCapture.title
        saveContext()
    }
    
    func deleteCapture(_ captureInfo: CoreCaptureInfo) {
        guard let capture = getCapture(id: captureInfo.id) else { return }
        context.delete(capture)
        saveContext()
    }
    
    func fetchCaptures() -> [CoreCaptureInfo] {
        let coreCaptures = getAllCaptures()
        return coreCaptures.compactMap({ capture -> CoreCaptureInfo? in
            guard let id = capture.id,
                  let imageData = capture.image,
                  let date = capture.date else { return nil}
            let title = capture.title
            return CoreCaptureInfo(id: id, imageData: imageData, date: date, title: title)
        })
    }
    
    private func getCapture(id: String) -> Capture? {
        let request = Capture.fetchRequest()
        
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let result = try context.fetch(request).first
            return result
        } catch {
            return nil
        }
    }
    
    private func getAllCaptures() -> [Capture] {
        let request = Capture.fetchRequest()
        
        do {
            let capture = try context.fetch(request)
            return capture
        } catch {
            return []
        }
    }
}
