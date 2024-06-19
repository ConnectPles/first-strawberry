//
//  MenuViewController.swift
//  ConnectPle
//
//  Created by Nolan Chen on 4/29/24.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var parentTableView: UITableView!
    
    let userAccount = UserManager.sharedInstance
    
    var selectedMenuItemName: String?
    var selectedMenuItemImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parentTableView.dataSource = self
        parentTableView.delegate = self
        parentTableView.rowHeight = CGFloat(CELL_HEIGHT)

        NotificationCenter.default.addObserver(self, selector: #selector(dataUpdated), name: Notification.Name("DataUpdated"), object: nil)

    }
    
    deinit {
        // Remove observer
        NotificationCenter.default.removeObserver(self, name: Notification.Name("DataUpdated"), object: nil)
    }
    
    @objc func dataUpdated() {
        // Reload the table view on the main thread
        DispatchQueue.main.async {
            self.parentTableView.reloadData()
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomMenuCell", for: indexPath) as! CustomMenuTableViewCell
        if let userProfile = self.userAccount.userProfile {
            let itemName = userProfile.getItemName(ByIndex: indexPath.row)
            if let itemName = itemName {
                switch itemName {
                    case DEFAULT_MENUITEM:
                        cell.customLabel.isHidden = false
                        cell.customImageView.isHidden = true
                        cell.customLabel.text = "Press \"+Add Dish\" below to start adding your dishes!"
                    default:
                        cell.customLabel.isHidden = false
                        cell.customImageView.isHidden = false
                        cell.customImageView.contentMode = .scaleAspectFill
                        
                        cell.customImageView.backgroundColor = .clear
                        cell.customImageView.contentMode = .scaleAspectFill
                        cell.customImageView.layer.masksToBounds = true
                        cell.customImageView.layer.cornerRadius = 10
                        cell.customImageView.layer.borderColor = UIColor.lightGray.cgColor
                        cell.customImageView.layer.borderWidth = 2.0
                    
                        cell.customLabel.text = itemName
                        let itemInfo = userProfile.getItemInfo(By: itemName)
                        self.userAccount.userProfile?.downloadImage(imageURL: itemInfo?.getImageURL(), completion: { resultImage in
                            if let image = resultImage {
                                cell.customImageView.image = image
                            }
                        })
                }
            } else {
                print("ERROR table cell: item name not found.")
                cell.isHidden = true
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        guard let count = self.userAccount.userProfile?.getMenuListNames().count else {
            return 0
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Update the data source
            self.userAccount.userProfile?.removeItem(ByIndex: indexPath.row, completion: { result in
                if result {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            })
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let userProfile = self.userAccount.userProfile else { return false }
        if userProfile.getMenuListCount() == 1 {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // Prevent selection of the "PLACE_HOLDER" cell at the unselectable index
        if self.userAccount.userProfile!.getItemName(ByIndex: indexPath.row) == DEFAULT_MENUITEM {
            return nil
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CustomMenuTableViewCell
        self.selectedMenuItemImage = cell.customImageView.image
        self.selectedMenuItemName = self.userAccount.userProfile!.getItemName(ByIndex: indexPath.row)
        performSegue(withIdentifier: "MenuToItemDetails", sender: self)
    }

    @IBAction func addDishButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "MenuToAddItem", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MenuToItemDetails" {
            if let navController = segue.destination as? UINavigationController, let destinationVC = navController.topViewController as? ItemDetailsViewController {
                destinationVC.receivedMenuItemName = self.selectedMenuItemName
                destinationVC.receivedImage = self.selectedMenuItemImage
            }
        }
    }
}
