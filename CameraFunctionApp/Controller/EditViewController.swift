//
//  EditViewController.swift
//  CameraFunctionApp
//
//  Created by pradnya on 15/04/24.
//

import UIKit
import FMPhotoPicker

class EditViewController: UIViewController {
    
    @IBOutlet weak var overlayText: UITextField!
    @IBOutlet weak var saveShareStackView: UIStackView!
    @IBOutlet weak var editImageView: UIImageView!
    
    var config = FMPhotoPickerConfig()
    let imagePicker = UIImagePickerController()
    var recivedImage: UIImage?
    
    var firstX: CGFloat = 0.0
    var firstY: CGFloat = 0.0
    var overlayTextLabel: UILabel!
    
    //MARK: ViewLifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterForKeyboardNotifications()
    }
    
    //MARK: Functional Methods
    func setUpUI() {
        guard let recivedImage else { return }
        editImageView.image = recivedImage
        toggleTextField(hide: true)
        overlayText.delegate = self
        configureStackView()
    }
    
    private func configureStackView() {
        saveShareStackView.layer.borderWidth = 1.0
        saveShareStackView.layer.borderColor = UIColor.black.cgColor
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func unregisterForKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func addPanGestureRecognizer(to view: UIView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        guard let view = sender.view else { return }
        moveViewWithPan(view: view, sender: sender)
        
    }
    
    private func moveViewWithPan(view: UIView, sender: UIPanGestureRecognizer) {
        
        let translatedPoint = sender.translation(in: view)
        
        if sender.state == .began {
            firstX = sender.view?.center.x ?? 0
            firstY = sender.view?.center.y ?? 0
        }
        
        let newCenter = CGPoint(x: firstX + translatedPoint.x, y: firstY + translatedPoint.y)
        sender.view?.center = newCenter
    }
    
    func toggleTextField(hide: Bool) {
        overlayText.isHidden = hide
    }
    
    func FMPInitialiSetup() {
        guard let recivedImage else { return }
        let editor = FMImageEditorViewController(config: config, sourceImage: recivedImage)
        editor.delegate = self
        self.present(editor, animated: true)
    }
    
    func setupSymbolImageView() {
        let symbolImageView = UIImageView(frame: CGRect(x: 160, y: 260, width: 50, height: 50))
        symbolImageView.image = UIImage(systemName: Constants.FACE_SMILING)
        symbolImageView.tintColor = UIColor.yellow
        symbolImageView.contentMode = .scaleAspectFit
        symbolImageView.isUserInteractionEnabled = true
        editImageView.isUserInteractionEnabled = true
        addPanGestureRecognizer(to: symbolImageView)
        
        editImageView.addSubview(symbolImageView)
    }
    
    func setUpOverlayText(_ textField: UITextField) {
        overlayTextLabel = UILabel(frame: CGRect(x: 160, y: 260, width: 250, height: 40))
        overlayTextLabel.text = textField.text
        overlayTextLabel.textColor = UIColor.black
        overlayTextLabel.font = UIFont(name: "MarkerFelt-Thin", size: 35)
        editImageView.addSubview(overlayTextLabel)
        editImageView.isUserInteractionEnabled = true
        overlayTextLabel.isUserInteractionEnabled = true
        
        addPanGestureRecognizer(to: overlayTextLabel)
    }
    
    func createImage(from imageView: UIImageView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, 0)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func saveEditedImage() {
        guard let image = createImage(from: editImageView) else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeMutableRawPointer) {
        if error != nil {
            UIHelper.showAlert(self, title: Constants.ERROR, message: Constants.ALERT_ERROR_MSG)
        } else {
            UIHelper.showAlert(self, title: Constants.SUCCESS, message: Constants.ALERT_SUCCESS_MSG)
        }
    }
    
    func presentShareSheet() {
        guard let imageToShare = createImage(from: editImageView) else {
            debugPrint("Failed to capture image")
            return
        }
        
        let itemsToShare: [Any] = [imageToShare]
        
        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    //MARK: IBAction Methods
    @IBAction func filterButtonTapped(_ sender: UIButton) {
        toggleTextField(hide: true)
        FMPInitialiSetup()
    }
    
    @IBAction func addOverlayImageButtonPressed(_ sender: Any) {
        toggleTextField(hide: true)
        setupSymbolImageView()
    }
    
    @IBAction func AddTextOnImageButtonPressed(_ sender: Any) {
        toggleTextField(hide: false)
    }
    
    @IBAction func changeBackgroundImageButtonPressed(_ sender: Any) {
        toggleTextField(hide: true)
        self.editImageView.backgroundColor = UIColor(cgColor: UIColor.systemYellow.cgColor)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        saveEditedImage()
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        presentShareSheet()
    }
    
}

//MARK: FMImageEditorViewControllerDelegate Methods
extension EditViewController: FMImageEditorViewControllerDelegate {
    
    func fmImageEditorViewController(_ editor: FMPhotoPicker.FMImageEditorViewController, didFinishEdittingPhotoWith photo: UIImage) {
        editImageView.image = photo
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: UITextFieldDelegate Methods
extension EditViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        setUpOverlayText(textField)
        textField.resignFirstResponder()
        toggleTextField(hide: true)
        overlayText.text = ""
        
        return true
    }
}

//MARK: Keyboard Hide/Show Methods
extension EditViewController {
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        var shouldMoveViewUp = false
        
        if let activeTextField = overlayText {
            let bottomOfTextField = activeTextField.convert(activeTextField.bounds, to: self.view).maxY;
            let topOfKeyboard = self.view.frame.height - keyboardSize.height
            
            if bottomOfTextField > topOfKeyboard {
                shouldMoveViewUp = true
            }
        }
        
        if(shouldMoveViewUp) {
            self.view.frame.origin.y = 0 - keyboardSize.height
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
}

/* for background Image
 func changeImageBackground(originalImage: UIImage, newBackgroundImage: UIImage) -> UIImage? {
 
 UIGraphicsBeginImageContextWithOptions(originalImage.size, false, originalImage.scale)
 
 newBackgroundImage.draw(in: CGRect(origin: .zero, size: originalImage.size))
 
 originalImage.draw(in: CGRect(origin: .zero, size: originalImage.size))
 
 let resultImage = UIGraphicsGetImageFromCurrentImageContext()
 
 UIGraphicsEndImageContext()
 
 return resultImage
 }
 */
