import Foundation

enum LayoutState: Int {
    case list, grid
    
    var numberOfColumns: Int {
        switch self {
        case .list:
            1
        case .grid:
            2
        }
    }
}

enum ArrayChange {
    case added(capture: CaptureInfo)
    case removed(capture: CaptureInfo)
    
    var capture: CaptureInfo {
        switch self {
        case .added(let capture), .removed(let capture):
            capture
        }
    }
}
