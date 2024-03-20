import UIKit

struct CoreCaptureInfo {
    var id: String
    var imageData: Data
    var date: Date
    var title: String?
    
    var preparedInfo: CaptureInfo? {
        guard let image = UIImage(data: imageData) else { return nil }
        return CaptureInfo(id: id, image: image, date: date, title: title)
    }
}

enum CaptureDescription: Hashable {
    case `default`(date: Date, capturesThisDay: Int)
    case userChanged(string: String)
    
    var description: String {
        switch self {
        case .default(let date, let capturesThisDay):
            "\(date.formattedDate)(\(capturesThisDay))"
        case .userChanged(let string):
            string
        }
    }
    
    var savableText: String? {
        switch self {
        case .default:
            nil
        case .userChanged:
            description
        }
    }
}

struct CaptureInfo: Equatable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine("\(id),\(date)")
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: String
    var image: UIImage
    var date: Date
    
    var title: CaptureDescription?
    var previewImage: UIImage?
    
    init(id: String, image: UIImage, date: Date, title: String?) {
        self.id = id
        self.image = image
        self.previewImage = image.resizedToPreview()
        self.date = date
        if let title {
            self.title = .userChanged(string: title)
        }
    }
    
    init(id: String, image: UIImage, date: Date, title: CaptureDescription?) {
        self.id = id
        self.image = image
        self.previewImage = image.resizedToPreview()
        self.date = date
        self.title = title
    }
    
    init(image: UIImage) {
        self.id = UUID().uuidString
        self.image = image
        self.previewImage = image.resizedToPreview()
        
        self.date = Date()
    }
    
    var coreInfo: CoreCaptureInfo? {
        guard let imageData = image.jpegData(compressionQuality: 1) else { return nil }
        return CoreCaptureInfo(id: id, imageData: imageData, date: date, title: title?.savableText)
    }
    
    func withUpdatedDescription(capturesThisDay: Int) -> CaptureInfo {
        let title = title ?? .default(date: date, capturesThisDay: capturesThisDay)
        return CaptureInfo(id: id, image: image, date: date, title: title)
    }
}
