//
//  MenuViewController.swift
//  ConnectPle
//
//  Created by Nolan Chen on 4/29/24.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var tableView: UITableView!
    
    let userAccount = UserManager.sharedInstance
    
    var selectedMenuItemName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 80 // Set your desired height here

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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedMenuItemName = self.userAccount.userProfile!.getItemName(ByIndex: indexPath.row)
        performSegue(withIdentifier: "showDestination", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MenuToEditItem" {
            if let destinationVC = segue.destination as? ItemDetailsViewController {
                destinationVC.receivedMenuItemName = self.selectedMenuItemName
            }
        }
    }

    @IBAction func addDishButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "MenuToEditItem", sender: self)
    }
}
