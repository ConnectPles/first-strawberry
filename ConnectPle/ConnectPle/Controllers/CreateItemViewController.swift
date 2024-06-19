//
//  CreateItemViewController.swift
//  ConnectPle
//
//  Created by Nolan Chen on 6/15/24.
//

import UIKit

extension UIImage {
    func isEqual(to image: UIImage) -> Bool {
        guard let data1 = self.jpegData(compressionQuality: 1.0),
              let data2 = image.jpegData(compressionQuality: 1.0) else {
            return false
        }
        return data1 == data2
    }
}

class CreateItemViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var itemImageView: UIImageView!
    
    @IBOutlet weak var itemNameTextfield: UITextField!
    
    @IBOutlet weak var itemDescriptionTextfield: UITextField!
    
    @IBOutlet weak var alarmLabel: UILabel!
    
    @IBOutlet weak var firstStarBtn: UIButton!
    
    @IBOutlet weak var secondStarBtn: UIButton!
    
    @IBOutlet weak var thirdStarBtn: UIButton!
    
    @IBOutlet weak var darkenedImageView: DarkenedImageView!
    
    
    let userAccount = UserManager.sharedInstance
    private var noImage = UIImage(named: "NoImage")
    private var alertDismissWorkItem: DispatchWorkItem?
    private var rateCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.darkenedImageView.hideLoading()
        
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
        do {// itemDesriptionTextfield setup
            self.itemDescriptionTextfield.delegate = self
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
        do {// retrieve keyboard on background tap
            do {//set dismiss keyboard
                let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
               view.addGestureRecognizer(dismissTap)
            }
            
        }
        
    }
    
    // UITextFieldDelegate method to enforce no leading white spaces for the first text field
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.itemNameTextfield {
            let currentText = textField.text ?? ""
            let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            if updatedText.hasPrefix(" ") || updatedText.count >= 30 {
                self.showTemporaryAlert(message: "Name cannot exceed 30 letters")
                return false
            }
        } else if textField == self.itemDescriptionTextfield {
            if let currentText = textField.text {
                if currentText.count >= 4000 {
                    self.showTemporaryAlert(message: "Description cannot exceed 1000 letters")
                }
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    //for dismiss keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
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
                
                self.darkenedImageView.showLoading()
                
                if newImage.isEqual(to: self.noImage!) == false {
                    self.userAccount.userProfile?.uploadImageToFirebaseStorage(image: newImage, completion: { uploadResult in
                        guard let newImageURL = URL(string: uploadResult!) else {
                            print("Invalid URL string.")
                            
                            self.darkenedImageView.hideLoading()
                            
                            return
                        }
                        self.userAccount.userProfile?.addItem(itemName: newItemName, rate: self.rateCount, imageURL: newImageURL, description: self.itemDescriptionTextfield.text, completion: { addResult in
                            if addResult {
                                NotificationCenter.default.post(name: Notification.Name("DataUpdated"), object: nil)
                                self.dismiss(animated: true)
                            } else {
                                self.showTemporaryAlert(message: "Save new dish failed. Please try again later")
                            }
                            
                            self.darkenedImageView.hideLoading()
                            
                        })
                    })
                } else {
                    self.userAccount.userProfile?.addItem(itemName: newItemName, rate: self.rateCount, imageURL: nil, description: self.itemDescriptionTextfield.text, completion: { result in
                        if result {
                            NotificationCenter.default.post(name: Notification.Name("DataUpdated"), object: nil)
                            self.dismiss(animated: true)
                        } else {
                            self.showTemporaryAlert(message: "Save new dish failed. Please try again later")
                        }
                        
                        self.darkenedImageView.hideLoading()
                        
                    })
                }
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
        let documentPickerController = UIDocumentPickerViewController(documentTypes: ["public.image"], in: .import)
        documentPickerController.delegate = self
        self.present(documentPickerController, animated: true, completion: nil)
    }
    
    func showTemporaryAlert(message: String, duration: TimeInterval = 2.0) {
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
