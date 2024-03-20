import Foundation

protocol CaptureDeletable: StorageService {
    func deleteCapture(_ captureInfo: CaptureInfo)
}

final class CaptureDeleter: CaptureDeletable {
    func deleteCapture(_ captureInfo: CaptureInfo) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let coreInfo = captureInfo.coreInfo else { return }
            self?.service.deleteCapture(coreInfo)
        }
    }
}
