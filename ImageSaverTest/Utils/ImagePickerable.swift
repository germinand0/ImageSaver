import UIKit
import Photos

protocol ImagePickerable: UIImagePickerControllerDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate {}

extension ImagePickerable where Self: UIViewController {
    func presentCameraPicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
}
