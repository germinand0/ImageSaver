import Foundation

protocol CaptureEditable: StorageService {
    func changeCapture(_ actualCapture: CaptureInfo)
}

final class CaptureEditor: CaptureEditable {
    func changeCapture(_ actualCapture: CaptureInfo) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let coreInfo = actualCapture.coreInfo else { return }
            self?.service.changeCapture(coreInfo)
        }
    }
}
