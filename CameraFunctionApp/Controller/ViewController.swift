//
//  ViewController.swift
//  CameraFunctionApp
//
//  Created by pradnya on 15/04/24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var previewImageView: UIImageView!
    
    var capturedImage: UIImage?
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }
    
    //MARK: Functional Methods
    func navigateToEditVC() {
        let storyboard = UIStoryboard(name: Constants.storyboardIdentifiers.Main, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: Constants.storyboardIdentifiers.EditViewController) as! EditViewController
        
        vc.recivedImage = capturedImage
        navigationController?.pushViewController(vc,
                                                 animated: true)
    }
    
    //MARK: IBAction Methods
    @IBAction func captureButtonTapped(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        } else {
            debugPrint("Camera is not available")
        }
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        navigateToEditVC()
    }
    
}


//MARK: ImagePcker Delegate Methods
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            previewImageView.image = selectedImage
            capturedImage = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

