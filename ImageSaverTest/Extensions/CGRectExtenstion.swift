import UIKit

extension CGSize: Comparable {
    public static func /(lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
    }
    
    public static func <(lhs: CGSize, rhs: CGSize) -> Bool {
        return (lhs.width < rhs.width) || (lhs.height < rhs.height)
    }
    
    func adjustTo(toSize: CGSize) -> CGSize {
        let widthRatio = toSize.width / width
        let heightRatio = toSize.height / height
        
        let aspect = self < toSize ? min(widthRatio, heightRatio) : max(widthRatio, heightRatio)
        return CGSize(width: width * aspect, height: height * aspect)
    }
}
