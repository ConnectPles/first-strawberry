//
//  CreateItemViewController.swift
//  ConnectPle
//
//  Created by Nolan Chen on 6/15/24.
//

import UIKit
import UniformTypeIdentifiers

extension UIImage {
    func isEqual(to image: UIImage) -> Bool {
        guard let data1 = self.jpegData(compressionQuality: 1.0),
              let data2 = image.jpegData(compressionQuality: 1.0) else {
            return false
        }
        return data1 == data2
    }
}

class CreateItemViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var itemImageView: UIImageView!
    
    @IBOutlet weak var itemNameTextfield: UITextField!
    
    @IBOutlet weak var itemDescriptionTextView: UITextView!
    
    @IBOutlet weak var alarmLabel: UILabel!
    
    @IBOutlet weak var firstStarBtn: UIButton!
    
    @IBOutlet weak var secondStarBtn: UIButton!
    
    @IBOutlet weak var thirdStarBtn: UIButton!
    
    @IBOutlet weak var loadingIndicatorImageView: LoadingIndicatorImageView!
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter your description here..."
        label.textColor = .lightGray
        return label
    }()
    
    let userAccount = UserManager.sharedInstance
    private var noImage = UIImage(named: "NoImage")
    private var alertDismissWorkItem: DispatchWorkItem?
    private var rateCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadingIndicatorImageView.hideLoading()
        
        
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        do {// retrieve keyboard on background tap
            //set dismiss keyboard
            let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            view.addGestureRecognizer(dismissTap)
        }
        
        do {//itemImage setup
            self.itemImageView.image = noImage
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
            self.itemImageView.addGestureRecognizer(tapGestureRecognizer)
            self.itemImageView.isUserInteractionEnabled = true
            
            self.itemImageView.backgroundColor = .clear
            self.itemImageView.contentMode = .scaleAspectFill
            self.itemImageView.layer.masksToBounds = true
            self.itemImageView.layer.cornerRadius = 10
            self.itemImageView.layer.borderColor = UIColor.lightGray.cgColor
            self.itemImageView.layer.borderWidth = 2.0
        }
        do {// itemNameTextfield setup
            self.itemNameTextfield.delegate = self
        }
        do {// itemDesriptionTextView setup
            self.itemDescriptionTextView.delegate = self
            self.itemDescriptionTextView.backgroundColor = .clear
            itemDescriptionTextView.layer.borderWidth = 1.0
            itemDescriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
            itemDescriptionTextView.layer.cornerRadius = 5.0
            // Add the placeholder label to the text view
            itemDescriptionTextView.addSubview(placeholderLabel)
            placeholderLabel.frame = CGRect(x: 5, y: 5, width: itemDescriptionTextView.bounds.width - 10, height: 20)
            placeholderLabel.isHidden = !itemDescriptionTextView.text.isEmpty
            
        }
        do {// alarmLabel setup
            self.alarmLabel.isHidden = true
            self.alarmLabel.backgroundColor = .init(white: 0.5, alpha: 0.5)
            self.alarmLabel.layer.borderColor = .init(gray: 1.0, alpha: 1.0)
            self.alarmLabel.layer.borderWidth = 2.0

            self.alarmLabel.alpha = 0.0
            self.alarmLabel.isUserInteractionEnabled = false
        }
        do {//star button setup
            self.firstStarBtn.setImage(UIImage(systemName: "star"), for: .normal)
            self.secondStarBtn.setImage(UIImage(systemName: "star"), for: .normal)
            self.thirdStarBtn.setImage(UIImage(systemName: "star"), for: .normal)
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
           let activeTextView = self.view.firstResponder as? UITextView {
            
            let keyboardHeight = keyboardFrame.height
            adjustViewForKeyboard(height: keyboardHeight, activeTextView: activeTextView)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        resetViewPosition()
    }
    
    func adjustViewForKeyboard(height: CGFloat, activeTextView: UITextView) {
        let textViewFrame = activeTextView.convert(activeTextView.bounds, to: self.view)
        let bottomSpace = self.view.frame.height - (textViewFrame.origin.y + textViewFrame.height)
        
        if bottomSpace < height {
            let adjustmentHeight = height - bottomSpace + 20 // Add a bit of padding
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y = -adjustmentHeight
            }
        }
    }
    
    func resetViewPosition() {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
        }
    }
    
    
    //for dismiss keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: textField Delegate
    // UITextFieldDelegate method to enforce no leading white spaces for the first text field
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.itemNameTextfield {
            let currentText = textField.text ?? ""
            let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            if updatedText.hasPrefix(" ") || updatedText.count >= 30 {
                self.showTemporaryAlert(message: "Name cannot exceed 30 letters")
                return false
            }
        }
        return true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    //MARK: TextView delegate
    func textViewDidChange(_ textView: UITextView) {
        if textView == self.itemDescriptionTextView {
            if let currentText = textView.text {
                if currentText.count >= 4000 {
                    self.showTemporaryAlert(message: "Description cannot exceed 4000 letters")
                }
            }
            placeholderLabel.isHidden = !textView.text.isEmpty

        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    //MARK: Image picker delegate
    @objc func imageViewTapped() {
        // Create an action sheet
        let alert = UIAlertController(title: "Upload Image", message: "Choose an option", preferredStyle: .actionSheet)
        
        // Photo Library action
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.openPhotoLibrary()
        }
        alert.addAction(photoLibraryAction)
        
        // Files action
        let filesAction = UIAlertAction(title: "Files", style: .default) { _ in
            self.openFiles()
        }
        alert.addAction(filesAction)
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        // Present the action sheet
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func firstStarTapped(_ sender: UIButton) {
        if let image = sender.image(for: .normal) {
            if image.isEqual(to: UIImage(systemName: "star")!) {
                self.firstStarBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
                self.rateCount = 1
            } else if image.isEqual(to: UIImage(systemName: "star.fill")!) {
                self.firstStarBtn.setImage(UIImage(systemName: "star"), for: .normal)
                self.secondStarBtn.setImage(UIImage(systemName: "star"), for: .normal)
                self.thirdStarBtn.setImage(UIImage(systemName: "star"), for: .normal)
                self.rateCount = 0
            }
        }
    }
    
    @IBAction func secondStarTapped(_ sender: UIButton) {
        if let image = sender.image(for: .normal) {
            if image.isEqual(to: UIImage(systemName: "star")!) {
                self.firstStarBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
                self.secondStarBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
                self.rateCount = 2
            } else if image.isEqual(to: UIImage(systemName: "star.fill")!) {
                self.firstStarBtn.setImage(UIImage(systemName: "star"), for: .normal)
                self.secondStarBtn.setImage(UIImage(systemName: "star"), for: .normal)
                self.thirdStarBtn.setImage(UIImage(systemName: "star"), for: .normal)
                self.rateCount = 0
            }
        }
    }
    
    @IBAction func thirdStarTapped(_ sender: UIButton) {
        if let image = sender.image(for: .normal) {
            if image.isEqual(to: UIImage(systemName: "star")!) {
                self.firstStarBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
                self.secondStarBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
                self.thirdStarBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
                self.rateCount = 3
            } else if image.isEqual(to: UIImage(systemName: "star.fill")!) {
                self.firstStarBtn.setImage(UIImage(systemName: "star"), for: .normal)
                self.secondStarBtn.setImage(UIImage(systemName: "star"), for: .normal)
                self.thirdStarBtn.setImage(UIImage(systemName: "star"), for: .normal)
                self.rateCount = 0
            }
        }
    }
    
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        if var newItemName = itemNameTextfield.text {
            newItemName = newItemName.trimmingCharacters(in: .whitespacesAndNewlines)
            if newItemName.isEmpty {
                self.showTemporaryAlert(message: "Dish name cannot be empty!")
                return
            }
            if self.userAccount.userProfile!.checkIfItemNameExists(itemName: newItemName) {
                self.showTemporaryAlert(message: "Dish name existed")
                return
            }
            if let newImage = self.itemImageView.image {
                
                self.loadingIndicatorImageView.showLoading()
                
                let isImageDefault = newImage.isEqual(to: self.noImage!)
                
                self.userAccount.userProfile!.uploadImageToFirebaseStorage(
                    image: isImageDefault ? nil : newImage,
                    completion: { errorStr, resultURL in
                        var newImageURL: URL?
                        switch resultURL {
                            case nil:
                                switch errorStr {
                                case nil: //meaning there is no user upload image
                                    newImageURL = nil
                                default: // error during uploading image
                                    print(errorStr!)
                                    self.loadingIndicatorImageView.hideLoading()
                                    return
                                }
                            default: // image uploading successfully
                                newImageURL = resultURL
                        }
                        
                        self.userAccount.userProfile!.addItem(itemName: newItemName, rate: self.rateCount, imageURL: newImageURL, description: self.itemDescriptionTextView.text, completion: { addResult in
                            if addResult {
                                NotificationCenter.default.post(name: Notification.Name("DataUpdated"), object: nil)
                                self.dismiss(animated: true)
                            } else {
                                self.showTemporaryAlert(message: "Save new dish failed. Please try again later")
                            }
                            
                            self.loadingIndicatorImageView.hideLoading()
                            
                        })
                    })
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    private func openPhotoLibrary() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    private func openFiles() {
        let documentPickerController = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.image])
        documentPickerController.delegate = self
        self.present(documentPickerController, animated: true, completion: nil)
    }
    
    private func showTemporaryAlert(message: String, duration: TimeInterval = 2.0) {
        // Cancel any existing dismissal work item
        alertDismissWorkItem?.cancel()
        
        // Remove any ongoing animations
        self.alarmLabel.layer.removeAllAnimations()
        
        // Set the alert message
        self.alarmLabel.text = message
        
        // Ensure the label is visible
        self.alarmLabel.isHidden = false
        self.alarmLabel.alpha = 0.8
        
        // Schedule dismissal work item
        alertDismissWorkItem = DispatchWorkItem {
            self.dismissAlert()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: alertDismissWorkItem!)
    }
    
    private func dismissAlert() {
        UIView.animate(withDuration: 0.5, animations: {
            self.alarmLabel.alpha = 0.0
        }) { _ in
            self.alarmLabel.isHidden = true
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            self.itemImageView.image = selectedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UIDocumentPickerDelegate
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first, let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
            self.itemImageView.image = image
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

}
