import UIKit

protocol ReusableCell {
    static var reuseIdentifier: String { get }
}

extension ReusableCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: ReusableCell {}
extension UICollectionViewCell: ReusableCell {}

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell & ReusableCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Unable to dequeue reusable cell \(T.self) with identifier \(T.reuseIdentifier)")
        }
        return cell
    }
    
    func registerNib(_ cellClass: UITableViewCell.Type) {
        let nib = UINib(nibName: String(describing: cellClass), bundle: nil)
        register(nib, forCellReuseIdentifier: String(describing: cellClass))
    }
    
    func register(_ cellClass: UITableViewCell.Type) {
        register(cellClass, forCellReuseIdentifier: String(describing: cellClass))
    }
}

extension UICollectionView {
    func dequeueReusableCell<T: UICollectionViewCell & ReusableCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Unable to dequeue reusable cell \(T.self) with identifier \(T.reuseIdentifier)")
        }
        return cell
    }
    
    func registerNib(_ cellClass: UICollectionViewCell.Type) {
        let nib = UINib(nibName: String(describing: cellClass), bundle: nil)
        register(nib, forCellWithReuseIdentifier: String(describing: cellClass))
    }
}
