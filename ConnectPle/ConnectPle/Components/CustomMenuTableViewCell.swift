//
//  CustomTableViewCell.swift
//  ConnectPle
//
//  Created by Nolan Chen on 6/3/24.
//

import UIKit

protocol CustomMenuTableViewCellDelegate: AnyObject {
    func customMenuTableViewCell(_ cell: CustomMenuTableViewCell, didTapButton button: UIButton)
}

class CustomMenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var customLabel: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    weak var delegate: CustomMenuTableViewCellDelegate?

    
    @IBAction func addBtnTapped(_ sender: UIButton) {
        delegate?.customMenuTableViewCell(self, didTapButton: sender)
    }
}
