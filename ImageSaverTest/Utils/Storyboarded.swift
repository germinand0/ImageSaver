import UIKit

protocol Storyboarded {
    static var storyboardName: String { get }
    static func instantiate() -> Self
}

extension Storyboarded where Self: UIViewController {
    static var storyboardName: String {
        return String(describing: self)
    }
    
    static func instantiate() -> Self {
        let identifier = String(describing: self)
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        
        guard let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as? Self else {
            fatalError("Failed to instantiate view controller with identifier \(identifier) from storyboard \(storyboardName).")
        }
        
        return viewController
    }
}
