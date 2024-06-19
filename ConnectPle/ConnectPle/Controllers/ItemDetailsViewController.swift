//
//  EditItemViewController.swift
//  ConnectPle
//
//  Created by Nolan Chen on 6/14/24.
//

import UIKit

class ItemDetailsViewController: UIViewController, UIImagePickerControllerDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var itemImageView: UIImageView!
    
    @IBOutlet weak var itemNameTextField: UITextField!
    
    @IBOutlet weak var itemDescriptionTextfield: UITextField!
    
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
        
    @IBOutlet weak var parentStackView: UIStackView!
    
    var storedRightBarButtonItem: UIBarButtonItem?

    var receivedMenuItemName: String?
    var receivedImage: UIImage?
    var noImage = UIImage(named: "NoImage")
    
    let userAccount = UserManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {//set up right bar button
            let rightBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(rightBarButtonTapped))
            rightBarButton.tintColor = .gray
            storedRightBarButtonItem = rightBarButton
        }
        do {//itemImage setup
            self.itemImageView.image = self.receivedImage ?? noImage
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
            self.itemNameTextField.text = self.receivedMenuItemName ?? ""
            self.itemNameTextField.backgroundColor = .clear
            self.itemNameTextField.isUserInteractionEnabled = false
        }
        do {//itemDescription setup
            if let itemName = self.receivedMenuItemName, let itemInfo = self.userAccount.userProfile!.getItemInfo(By: itemName) {
                self.itemDescriptionTextfield.text = itemInfo.getDescription()
            }
            self.itemDescriptionTextfield.backgroundColor = .clear
            self.itemDescriptionTextfield.isUserInteractionEnabled = false
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.leftBarButton.title = "Edit"
    }

    @IBAction func leftBarButtonTapped(_ sender: UIBarButtonItem) {
        switch sender.title {
        case "Edit":
            self.leftBarButton.title = "Save"
            self.showRightBarButton()
            self.enableImageUpload()
            self.shakeParentStackView()
            self.itemNameTextField.isUserInteractionEnabled = true
            self.itemDescriptionTextfield.isUserInteractionEnabled = true
        default:
            self.leftBarButton.title = "Edit"
            self.hideRightBarButton()
            self.disableImageUpload()
            self.stopShakeParentStackView()
            self.itemNameTextField.isUserInteractionEnabled = false
            self.itemDescriptionTextfield.isUserInteractionEnabled = false
        }
    }
    
    @objc func rightBarButtonTapped() {
        self.leftBarButton.title = "Edit"
        self.hideRightBarButton()
        self.disableImageUpload()
        self.stopShakeParentStackView()
        self.itemNameTextField.isUserInteractionEnabled = false
        self.itemDescriptionTextfield.isUserInteractionEnabled = false
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
    
    private func hideRightBarButton() {
        self.navigationItem.rightBarButtonItem = nil
    }
    
    private func showRightBarButton() {
        self.navigationItem.rightBarButtonItem = storedRightBarButtonItem
    }
    
    private func enableImageUpload() {
        self.itemImageView.isUserInteractionEnabled = true
    }
    
    private func disableImageUpload() {
        self.itemImageView.isUserInteractionEnabled = false
    }
    
    private func shakeParentStackView() {
        let shakeAnimation = CABasicAnimation(keyPath: "position")
        shakeAnimation.duration = 0.3
        shakeAnimation.repeatCount = Float.infinity
        shakeAnimation.autoreverses = true
        shakeAnimation.fromValue = NSValue(cgPoint: CGPoint(x: parentStackView.center.x - 2, y: parentStackView.center.y - 2))
        shakeAnimation.toValue = NSValue(cgPoint: CGPoint(x: parentStackView.center.x + 2, y: parentStackView.center.y + 2))
        parentStackView.layer.add(shakeAnimation, forKey: "position")
    }
    private func stopShakeParentStackView() {
        parentStackView.layer.removeAnimation(forKey: "position")
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
