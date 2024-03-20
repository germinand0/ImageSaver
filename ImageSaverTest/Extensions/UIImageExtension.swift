import UIKit
import AVFoundation

extension UIImage {
    func getImageAndClear(completion: @escaping (() -> (UIImage))) -> UIImage {
        return autoreleasepool { () -> UIImage in
            let image = completion()
            return image
        }
    }
    
    /**
     Calculates the best height of the image for available width.
     */
    func height(forWidth width: CGFloat) -> CGFloat {
        let boundingRect = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: CGFloat(MAXFLOAT)
        )
        let rect = AVMakeRect(
            aspectRatio: size,
            insideRect: boundingRect
        )
        return rect.size.height
    }
    
    func size(in rect: CGRect) -> CGSize {
        return AVMakeRect(aspectRatio: size, insideRect: rect).size
    }
    
    func resized(to newSize: CGSize, scale: CGFloat = 1, actions: ((UIGraphicsImageRendererContext) -> ())? = nil) -> UIImage {
        return getImageAndClear {
            let format = UIGraphicsImageRendererFormat.default()
            format.scale = scale
            let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
            let image = renderer.image { ctx in
                guard let actions = actions else {
                    self.draw(in: CGRect(origin: .zero, size: newSize))
                    return
                }
                actions(ctx)
            }
            return image
        }
    }
    
    func resizedToPreview() -> UIImage {
        let size = size.adjustTo(toSize: CGSize(width: 300, height: 300))
        let resizedImage = resized(to: size)
        return resizedImage
    }
    
    func withFixedOrientation() -> UIImage? {
        if self.imageOrientation == .up {
            return self
        }
        
        var transform = CGAffineTransform.identity
        
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by:  CGFloat(Double.pi / 2))
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by:  -CGFloat(Double.pi / 2))
        default:
            break
        }
        
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        guard let context = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue) else {
            return self
        }
        
        context.concatenate(transform)
        
        guard let cgImage = self.cgImage else { return self }
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width))
        default:
            context.draw(cgImage, in: CGRect(origin: .zero, size: self.size))
        }
        
        guard let CGImage = context.makeImage() else {
            return self
        }
        
        return UIImage(cgImage: CGImage)
    }
}
