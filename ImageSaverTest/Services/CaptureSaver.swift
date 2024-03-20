import Foundation

protocol CaptureSavable: StorageService {
    func saveCapture(_ captureInfo: CaptureInfo)
}

final class CaptureSaver: CaptureSavable {
    func saveCapture(_ captureInfo: CaptureInfo) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let coreInfo = captureInfo.coreInfo else { return }
            self?.service.saveCapture(coreInfo)
        }
    }
}
