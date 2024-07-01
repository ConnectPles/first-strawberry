//
//  EditItemViewController.swift
//  ConnectPle
//
//  Created by Nolan Chen on 6/14/24.
//

import UIKit
import UniformTypeIdentifiers

extension UIView {
    var firstResponder: UIResponder? {
        guard !isFirstResponder else { return self }
        for subview in subviews {
            if let responder = subview.firstResponder {
                return responder
            }
        }
        return nil
    }
}

class ItemDetailsViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var itemImageView: UIImageView!
    
    @IBOutlet weak var itemNameTextField: UITextField!
    
    @IBOutlet weak var itemDescriptionTextView: UITextView!
    
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
        
    @IBOutlet weak var parentStackView: UIStackView!
    
    @IBOutlet weak var loadingIndicatorImageView: LoadingIndicatorImageView!
    
    @IBOutlet weak var firstStarBtn: UIButton!
    
    @IBOutlet weak var secondStarBtn: UIButton!
    
    @IBOutlet weak var thirdStarBtn: UIButton!
    
    @IBOutlet weak var alarmLabel: UILabel!
    
    var storedRightBarButtonItem: UIBarButtonItem?

    var receivedMenuItemName: String?
    var previousImage: UIImage?
    var receivedImage: UIImage?
    var rateCount: Int = 0
    
    let noImage = UIImage(named: "NoImage")
    private var alertDismissWorkItem: DispatchWorkItem?

    let userAccount = UserManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.itemDescriptionTextView.delegate = self

        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        do {// retrieve keyboard on background tap
            //set dismiss keyboard
            let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            view.addGestureRecognizer(dismissTap)
        }
        
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadingIndicatorImageView.hideLoading()
        
        self.disableEditing()
                
        do {// alarmLabel setup
            self.alarmLabel.isHidden = true
            self.alarmLabel.backgroundColor = .init(white: 0.5, alpha: 0.5)
            self.alarmLabel.layer.borderColor = .init(gray: 1.0, alpha: 1.0)
            self.alarmLabel.layer.borderWidth = 2.0

            self.alarmLabel.alpha = 0.0
            self.alarmLabel.isUserInteractionEnabled = false
        }
        do {//set up rate stars
            self.firstStarBtn.setImage(UIImage(systemName: "star"), for: .normal)
            self.secondStarBtn.setImage(UIImage(systemName: "star"), for: .normal)
            self.thirdStarBtn.setImage(UIImage(systemName: "star"), for: .normal)
            
            if let itemName = self.receivedMenuItemName, let item = self.userAccount.userProfile!.getItemInfo(By: itemName) {
                let rate = item.getRate()
                self.rateCount = rate
                switch rate {
                case 1:
                    self.firstStarBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
                case 2:
                    self.firstStarBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
                    self.secondStarBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
                case 3:
                    self.firstStarBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
                    self.secondStarBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
                    self.thirdStarBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
                default: break
                }
            }
        }
        do {//set up left bar button
            self.leftBarButton.title = "Edit"
        }
        do {//set up right bar button
            let rightBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(rightBarButtonTapped))
            rightBarButton.tintColor = .gray
            storedRightBarButtonItem = rightBarButton
        }
        do {//itemImage setup
            self.itemImageView.image = self.receivedImage ?? noImage
            
            self.previousImage = self.itemImageView.image
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
            self.itemImageView.addGestureRecognizer(tapGestureRecognizer)
            self.itemImageView.isUserInteractionEnabled = false
            self.itemImageView.backgroundColor = .clear
            self.itemImageView.contentMode = .scaleAspectFill
            self.itemImageView.layer.masksToBounds = true
            self.itemImageView.layer.cornerRadius = 10
            self.itemImageView.layer.borderColor = UIColor.lightGray.cgColor
            self.itemImageView.layer.borderWidth = 2.0
        }
        do {//itemName textfield setup
            self.itemNameTextField.text = self.receivedMenuItemName
            self.itemNameTextField.backgroundColor = .clear
            self.itemNameTextField.isUserInteractionEnabled = false
        }
        do {//itemDescription setup
            if let itemName = self.receivedMenuItemName, let itemInfo = self.userAccount.userProfile!.getItemInfo(By: itemName) {
                self.itemDescriptionTextView.text = itemInfo.getDescription()
            }
            self.itemDescriptionTextView.backgroundColor = .clear
            self.itemDescriptionTextView.isUserInteractionEnabled = false
            itemDescriptionTextView.layer.borderWidth = 1.0
            itemDescriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
            itemDescriptionTextView.layer.cornerRadius = 5.0
        }
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
    
    //MARK: itemDescriptionTextView delegate
    func textViewDidChange(_ textView: UITextView) {
        if textView == self.itemDescriptionTextView {
            if let currentText = textView.text {
                if currentText.count >= 4000 {
                    self.showTemporaryAlert(message: "Description cannot exceed 4000 letters")
                }
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
//    func textView(_ textView: UITextView, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if textView == self.itemDescriptionTextView {
//            if let currentText = textView.text {
//                if currentText.count >= 4000 {
//                    self.showTemporaryAlert(message: "Description cannot exceed 1000 letters")
//                }
//            }
//        }
//        return true
//    }

    @IBAction func leftBarButtonTapped(_ sender: UIBarButtonItem) {
        switch sender.title {
        case "Edit":
            self.leftBarButton.title = "Save"
            self.enableEditing()
        case "Save":
            self.leftBarButton.title = "Edit"
            self.disableEditing()
            self.saveButtonTapped()
        default: break
        }
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
    
    @objc func rightBarButtonTapped() {
        self.leftBarButton.title = "Edit"
        self.disableEditing()
        self.dismiss(animated: true)
    }
    
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
    
    //for dismiss keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    private func enableEditing() {
        self.navigationItem.rightBarButtonItem = self.storedRightBarButtonItem
        self.itemImageView.isUserInteractionEnabled = true
        self.itemNameTextField.isUserInteractionEnabled = false // item name cannot be edited
        self.itemDescriptionTextView.isUserInteractionEnabled = true
        self.firstStarBtn.isUserInteractionEnabled = true
        self.secondStarBtn.isUserInteractionEnabled = true
        self.thirdStarBtn.isUserInteractionEnabled = true

    }
    
    private func disableEditing() {
        self.navigationItem.rightBarButtonItem = nil
        self.itemImageView.isUserInteractionEnabled = false
        self.itemNameTextField.isUserInteractionEnabled = false // item name cannot be edited
        self.itemDescriptionTextView.isUserInteractionEnabled = false
        self.firstStarBtn.isUserInteractionEnabled = false
        self.secondStarBtn.isUserInteractionEnabled = false
        self.thirdStarBtn.isUserInteractionEnabled = false
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
        documentPickerController.allowsMultipleSelection = false

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
    
    private func saveButtonTapped() {
        if let itemName = self.itemNameTextField.text {
            if itemName.isEmpty || itemName != receivedMenuItemName {
                self.showTemporaryAlert(message: "Dish name cannot be modified!")
                return
            }
            if let newImage = self.itemImageView.image {
                
                self.loadingIndicatorImageView.showLoading()
                
                //Check if image is modified or default
                let isImageDefault = newImage.isEqual(to: self.noImage!)
                let isImageTouched = !newImage.isEqual(to: previousImage!)
                var shouldUploadImage = false
                if isImageTouched && isImageDefault {
                    self.showTemporaryAlert(message: "Unknown Error")
                    print("ERROR: image cannot be touched and default at the same time.")
                    self.loadingIndicatorImageView.hideLoading()
                    return
                } else if isImageTouched && !isImageDefault {
                    shouldUploadImage = true
                } else if !isImageTouched && isImageDefault {
                    shouldUploadImage = false
                }
                
                
                //if image touched, remove old storage
                if isImageTouched {
                    guard let currentImageURL = self.userAccount.userProfile?.getItemInfo(By: itemName)?.getImageURL() else {
                        self.showTemporaryAlert(message: "Current Dish image inaccessible.")
                        self.loadingIndicatorImageView.hideLoading()
                        return
                    }
                    self.userAccount.userProfile?.deleteImageFromFirebaseStorage(fromURL: currentImageURL, completion: { deleteError in
                        if deleteError != nil {
                            self.showTemporaryAlert(message: deleteError!)
                            self.loadingIndicatorImageView.hideLoading()
                            return
                        }
                    })
                }
                
                self.userAccount.userProfile!.uploadImageToFirebaseStorage(
                    image: shouldUploadImage ? newImage : nil,
                    completion: { errorStr, resultURL in
                        var newImageURL: URL?
                        switch resultURL {
                            case nil:
                                switch errorStr {
                                case nil: //meaning there is no update on image
                                    newImageURL = nil
                                default: // error during uploading image
                                    self.showTemporaryAlert(message: errorStr! + "Update Dish failed. Please try again later")
                                    self.loadingIndicatorImageView.hideLoading()
                                    return
                                }
                            default: // image uploading successfully
                                newImageURL = resultURL
                        }
                        
                        self.userAccount.userProfile!.updateItem(itemName: itemName, newRate: self.rateCount, newImageURL: newImageURL, newDescription: self.itemDescriptionTextView.text, completion: { updateResult in
                            if updateResult {
                                NotificationCenter.default.post(name: Notification.Name("DataUpdated"), object: nil)
                                self.dismiss(animated: true)
                            } else {
                                self.showTemporaryAlert(message: "Update dish failed. Please try again later")
                            }
                            
                        })
                        self.loadingIndicatorImageView.hideLoading()
                    })
                
            }
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
