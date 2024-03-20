import Foundation

protocol CaptureFetchable: StorageService {
    func fetchCaptures(completion: @escaping (([CaptureInfo]) -> ()))
}

final class CaptureFetcher: CaptureFetchable {
    func fetchCaptures(completion: @escaping (([CaptureInfo]) -> ())) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let coreInfo = self?.service.fetchCaptures()
            let captureInfo = coreInfo?.compactMap({$0.preparedInfo}) ?? []
            DispatchQueue.main.async {
                completion(captureInfo)
            }
        }
    }
}
