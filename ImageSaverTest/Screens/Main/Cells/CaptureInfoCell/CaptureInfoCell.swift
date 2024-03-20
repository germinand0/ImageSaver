import UIKit

final class CaptureInfoCell: UICollectionViewCell {
    
    @IBOutlet fileprivate weak var stackView: UIStackView!
    @IBOutlet fileprivate weak var avatarImageView: UIImageView!
    @IBOutlet fileprivate weak var nameListLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateContentStyle()
        cornerRadius = 16
    }
    
    func configure(with capture: CaptureInfo) {
        avatarImageView.image = capture.previewImage
        nameListLabel.text = capture.title?.description
    }
    
    private func updateContentStyle() {
        let isHorizontalStyle = bounds.width > 2 * bounds.height
        let oldAxis = stackView.axis
        let newAxis: NSLayoutConstraint.Axis = isHorizontalStyle ? .horizontal : .vertical
        guard oldAxis != newAxis else { return }

        stackView.axis = newAxis
        nameListLabel.textAlignment = isHorizontalStyle ? .left : .center
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
}
