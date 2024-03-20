import Foundation

protocol StorageService {
    var service: Storage { get }
}

extension StorageService {
    var service: Storage {
        CoreDataManager()
    }
}

protocol Storage {
    func saveCapture(_ captureInfo: CoreCaptureInfo)
    func changeCapture(_ actualCapture: CoreCaptureInfo)
    func deleteCapture(_ captureInfo: CoreCaptureInfo)
    func fetchCaptures() -> [CoreCaptureInfo]
}
