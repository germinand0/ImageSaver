import UIKit
 
final class DetailViewController: UIViewController, Storyboarded {
    private let titleButton = UIButton(type: .custom)
    private let contentImageView = UIImageView()
    
    private var firstPoint: CGPoint?
    private var lastPoint: CGPoint?
    
    private var viewModel: ViewModel?
    private var capture: CaptureInfo?
    
    static func configured(viewModel: ViewModel, capture: CaptureInfo) -> DetailViewController {
        let vc = DetailViewController.instantiate()
        vc.viewModel = viewModel
        vc.capture = capture
        return vc
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        layoutView()
        configureRecognizers()
    }
    
    private func layoutView() {
        guard let capture else { return }
        configureNavigation(with: capture.title?.description)
        layoutImageView(with: capture.image)
    }
    
    private func configureNavigation(with title: String?) {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                           target: self,
                                                           action: #selector(closeAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: #selector(closeAction))
        navigationController?.navigationBar.tintColor = .label
        
        titleButton.setTitle(title, for: .normal)
        titleButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleButton.addTarget(self, action: #selector(changeTitle), for: .touchUpInside)
        titleButton.sizeToFit()
        navigationItem.titleView = titleButton
    }
    
    @objc private func changeTitle() {
        let alertController = UIAlertController(title: "Rename", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { [weak self] (textField) in
            guard let self else { return }
            textField.text = capture?.title?.description
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        let doneAction = UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            guard let self, let textField = alertController.textFields?.first,
                  let enteredText = textField.text, !enteredText.isEmpty else { return }
            capture?.title = .userChanged(string: enteredText)
            configureNavigation(with: enteredText)
            if let capture {
                viewModel?.changeCapture(capture)
            }
        }
        alertController.addAction(doneAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func closeAction() {
        dismiss(animated: true)
    }
    
    private func layoutImageView(with image: UIImage) {
        contentImageView.frame.size = image.size(in: view.bounds)
        contentImageView.center = view.center
        contentImageView.isUserInteractionEnabled = true
        contentImageView.image = image
        view.addSubview(contentImageView)
    }
    
    private func configureRecognizers() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureDetected(_:)))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGestureDetected(_:)))
        
        [panGesture, pinchGesture].forEach { gesture in
            gesture.delegate = self
            gesture.cancelsTouchesInView = false
            contentImageView.addGestureRecognizer(gesture)
        }
    }
    
    @objc private func panGestureDetected(_ sender: UIPanGestureRecognizer) {
        let point = sender.translation(in: view)
        let transform = contentImageView.transform
        contentImageView.transform = transform.concatenating(CGAffineTransform(translationX: point.x,
                                                                         y: point.y))
        sender.setTranslation(.zero, in: view)
    }
    
    @objc private func pinchGestureDetected(_ sender: UIPinchGestureRecognizer) {
        typealias Zoom = (currentScale: CGFloat, direction: CGFloat)
        let zoom = Zoom(contentImageView.transform.a, sender.scale)
        let minimumScale: CGFloat = 0.3
        let maximumScale: CGFloat = 15
        
        if (zoom.currentScale < minimumScale && zoom.direction >= 1) || (zoom.currentScale > maximumScale && zoom.direction <= 1) || (minimumScale <= zoom.currentScale && zoom.currentScale <= maximumScale) {
            let location = sender.location(in: contentImageView)
            let pinchCenter = CGPoint(x: location.x - contentImageView.bounds.midX,
                                      y: location.y - contentImageView.bounds.midY)
            lastPoint = nil
            let transform = contentImageView.transform
            contentImageView.transform = transform
                .translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                .scaledBy(x: sender.scale, y: sender.scale)
                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
        }
        
        sender.scale = 1
        
        if sender.state == .ended {
            firstPoint = nil
            lastPoint = nil
            
            setIdentityIfNeeded(view: contentImageView)
        }
    }
    
    private func setIdentityIfNeeded(view: UIView?, completion: (() -> ())? = nil) {
        guard let view = view else {completion?(); return}
        if view.transform.a < 1 {
            zoom(view: view, zoomState: .default, completion: completion)
        }
    }
    
    private func zoom(view: UIView, zoomState: ZoomState,
              updateHandler: (() -> ())? = nil,
              completion: (() -> ())? = nil) {
        UIView.animate(withDuration: 0.3) {
            switch zoomState {
            case .default:
                view.transform = .identity
            case .custom(let center, let scale):
                let tapCenter = CGPoint(x: center.x - view.bounds.midX, y: center.y - view.bounds.midY)
                let transform = view.transform
                view.transform = transform
                    .translatedBy(x: tapCenter.x, y: tapCenter.y)
                    .scaledBy(x: scale, y: scale)
                    .translatedBy(x: -tapCenter.x, y: -tapCenter.y)
            }
            updateHandler?()
        } completion: { _ in
            completion?()
        }
    }
}

extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

fileprivate enum ZoomState {
    case `default`
    case custom(center: CGPoint, scale: CGFloat)
}
