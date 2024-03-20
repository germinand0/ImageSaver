import UIKit
import Combine

final class ViewController: UIViewController {
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    
    private var viewModelCancellable: AnyCancellable?
    private lazy var viewModel: ViewModel = {
        ViewModel()
    }()
    
    private var captures: [CaptureInfo] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private lazy var leftBarButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(origin: .zero, size: CGSize(width: 44, height: 44))
        button.setImage(UIImage(systemName: "photo.badge.plus"), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(photoAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var rightBarButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(origin: .zero, size: CGSize(width: 44, height: 44))
        button.setImage(currentLayout.iconImage, for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(changeLayoutAction), for: .touchUpInside)
        return button
    }()
    
    private var currentLayout: LayoutState = .list {
        didSet {
            updatePresentationStyle()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        sinkViewModel()
        configureCollectionView()
        configureNavigationBar()
    }
    
    private func sinkViewModel() {
        viewModelCancellable = viewModel.$captures
            .sink { [weak self] newValue in
                self?.captures = newValue.reversed()
            }
    }
    
    deinit {
        viewModelCancellable?.cancel()
    }

    private func configureNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBarButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)
    }

    private func configureCollectionView() {
        collectionView.registerNib(CaptureInfoCell.self)
        updatePresentationStyle()
    }
    
    private func updatePresentationStyle() {
        collectionView.performBatchUpdates({
            collectionView.reloadData()
        }, completion: nil)

        UIView.transition(with: rightBarButton, duration: 0.3, options: .transitionCrossDissolve) {
            self.rightBarButton.setImage(self.currentLayout.iconImage, for: .normal)
        }
    }
    
    @objc private func photoAction() {
        presentCameraPicker()
    }
    
    @objc private func changeLayoutAction() {
        switch currentLayout {
        case .list:
            currentLayout = .grid
        case .grid:
            currentLayout = .list
        }
    }
    
    private func openDetailedController(with capture: CaptureInfo) {
        let detailVC = DetailViewController.configured(viewModel: viewModel, capture: capture)
        let navigationVC = UINavigationController(rootViewController: detailVC)
        navigationVC.modalPresentationStyle = .overCurrentContext
        navigationVC.modalTransitionStyle = .crossDissolve
        present(navigationVC, animated: true)
    }
    
    private func makeContextAction(for indexPath: IndexPath) -> UIContextMenuConfiguration? {
        let delete = UIAction(
            title: "Delete",
            image: UIImage(systemName: "trash"),
            attributes: .destructive
        ) { [weak self] action in
            guard let self else { return }
            let capture = captures[indexPath.item]
            deleteCapture(capture)
        }
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying,
                                          actionProvider: { _ in
            return UIMenu(children: [delete])
        })
    }
    
    private func addCapture(_ capture: CaptureInfo) {
        viewModel.saveCapture(capture)
    }
    
    private func deleteCapture(_ capture: CaptureInfo) {
        viewModel.deleteCapture(capture)
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        captures.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CaptureInfoCell = collectionView.dequeueReusableCell(for: indexPath)
        let capture = captures[indexPath.item]
        
        cell.configure(with: capture)
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let capture = captures[indexPath.item]
        openDetailedController(with: capture)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        makeContextAction(for: indexPath)
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    private var itemsPerRow: CGFloat {
        CGFloat(currentLayout.numberOfColumns)
    }
    
    private var sectionInsets: UIEdgeInsets {
        switch currentLayout {
        case .list:
            .zero
        case .grid:
            UIEdgeInsets(top: 16.0, left: 16.0, bottom: 20.0, right: 16.0)
        }
    }
    
    private var minimumItemSpacing: CGFloat {
        8
    }
    
    private var minimumLineSpacing: CGFloat {
        switch currentLayout {
        case .list:
            10
        case .grid:
            20
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let capture = captures[indexPath.item]
        switch currentLayout {
        case .list:
            let paddingSpace = sectionInsets.left + sectionInsets.right
            let width = collectionView.bounds.width - paddingSpace
            let height = getCellHeight(with: capture, with: width)
            return CGSize(width: width, height: height)
        case .grid:
            let paddingSpace = sectionInsets.left + sectionInsets.right + minimumItemSpacing * (itemsPerRow - 1)
            let availableWidth = collectionView.bounds.width - paddingSpace
            let width = availableWidth / itemsPerRow
            
            let height = getCellHeight(with: capture, with: width)
            return CGSize(width: width, height: height)
        }
    }
    
    private func getCellHeight(with capture: CaptureInfo, with width: CGFloat) -> CGFloat {
        let title = capture.title?.description ?? ""
        let stringHeight = title.heightForWidth(width, font: UIFont.systemFont(ofSize: 16,
                                                                               weight: .semibold))
        
        switch currentLayout {
        case .list:
            return 100
        case .grid:
            return width + stringHeight + 15
        }
    }
}

extension ViewController: ImagePickerable {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let resultImage = (info[.originalImage] as? UIImage)?.withFixedOrientation() else { return }

        picker.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            let capture = CaptureInfo(image: resultImage)
            addCapture(capture)
        }
    }
}

fileprivate extension LayoutState {
    var iconImage: UIImage? {
        switch self {
        case .list:
            return UIImage(systemName: "list.dash")
        case .grid:
            return UIImage(systemName: "square.grid.2x2")
        }
    }
}
