import Foundation
import Combine

final class ViewModel: CaptureSavable, CaptureDeletable, CaptureFetchable, CaptureEditable {
    private lazy var captureSaver: CaptureSaver = {
        CaptureSaver()
    }()
    
    private lazy var captureDeleter: CaptureDeleter = {
        CaptureDeleter()
    }()
    
    private lazy var captureEditor: CaptureEditor = {
        CaptureEditor()
    }()
    
    private lazy var captureFetcher: CaptureFetcher = {
        CaptureFetcher()
    }()
    
    @Published var captures: [CaptureInfo] = []
    @Published private var tempCaptures: [CaptureInfo] = []
    
    private var groupedDict: [Int : Int] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        observeChanges()
        fetchCaptures()
    }
    
    private func fetchCaptures() {
        fetchCaptures { [weak self] captures in
            guard let self else { return }
            configureGroupedDict(from: captures.compactMap({ArrayChange.added(capture: $0)}))
            tempCaptures = captures
        }
    }
    
    func saveCapture(_ captureInfo: CaptureInfo) {
        configureGroupedDict(from: .added(capture: captureInfo))
        tempCaptures.append(captureInfo)
        captureSaver.saveCapture(captureInfo)
    }
    
    func deleteCapture(_ captureInfo: CaptureInfo) {
        configureGroupedDict(from: .removed(capture: captureInfo))
        tempCaptures.removeAll(where: {$0.id == captureInfo.id})
        captureDeleter.deleteCapture(captureInfo)
    }
    
    func changeCapture(_ actualCapture: CaptureInfo) {
        if let index = captures.firstIndex(where: {$0.id == actualCapture.id}) {
            tempCaptures[index] = actualCapture
        }
        captureEditor.changeCapture(actualCapture)
    }
    
    func fetchCaptures(completion: @escaping (([CaptureInfo]) -> ())) {
        captureFetcher.fetchCaptures(completion: completion)
    }
}

fileprivate extension ViewModel {
    func observeChanges() {
        $tempCaptures
            .map({ [weak self] captures in
                guard let self else { return [] }
                return captures.compactMap { capture -> CaptureInfo? in
                    return capture.withUpdatedDescription(capturesThisDay: self.groupedDict[capture.date.day] ?? 0)
                }
            })
            .assign(to: \.captures, on: self)
            .store(in: &cancellables)
    }
    
    func configureGroupedDict(from changes: [ArrayChange]) {
        changes.forEach({configureGroupedDict(from: $0)})
    }
    
    func configureGroupedDict(from change: ArrayChange) {
        var capturesThisDay = groupedDict[change.capture.date.day] ?? 0
        switch change {
        case .added:
            print("Added: \(change.capture.id)")
            capturesThisDay += 1
        case .removed:
            print("Removed: \(change.capture.id)")
            capturesThisDay -= 1
        }
        groupedDict[change.capture.date.day] = capturesThisDay
    }
}
