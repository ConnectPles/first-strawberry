//
//  MenuViewController.swift
//  ConnectPle
//
//  Created by Nolan Chen on 4/29/24.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CustomMenuTableViewCellDelegate {
    

    @IBOutlet weak var tableView: UITableView!
    
    let userAccount = UserManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomMenuCell", for: indexPath) as! CustomMenuTableViewCell
        cell.delegate = self
        if let userProfile = self.userAccount.userProfile {
            let itemNames = Array(userProfile.getList().keys)
            if itemNames[indexPath.row] == DEFAULT_MENUITEM {
                cell.customLabel.isHidden = true
                cell.customImageView.isHidden = true
                cell.addBtn.isHidden = false
            } else {
                cell.customLabel.isHidden = false
                cell.customImageView.isHidden = false
                cell.addBtn.isHidden = true
                
                cell.customLabel.text = itemNames[indexPath.row]
                let item = userProfile.getItem(itemKey: itemNames[indexPath.row])
                self.userAccount.userProfile?.downloadImage(imageURL: item?.getImageURL(), completion: { resultImage in
                    if let image = resultImage {
                        cell.customImageView.image = image
                    }
                })
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.userAccount.userProfile?.getList().count ?? 1
    }
    
    func customMenuTableViewCell(_ cell: CustomMenuTableViewCell, didTapButton button: UIButton) {
        print("tapped")
    }

}
