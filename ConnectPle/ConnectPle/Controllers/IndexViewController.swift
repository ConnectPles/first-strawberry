//
//  IndexViewController.swift
//  ConnectPle
//
//  Created by Nolan Chen on 2/16/24.
//

import UIKit

class IndexViewController: UIViewController {

    @IBOutlet weak var verticalLabel: UILabel!
    @IBOutlet weak var logInBtn: UIButton!
    
    
    let beginPosition = INDEX_VERTICAL_LABEL_BEGIN_POSITION
    let endPosition = INDEX_VERTICAL_LABEL_END_POSITION
    var labelHeight: CGFloat?
    var labelWidth: CGFloat?
    var logInBtnHeight: CGFloat?
    var logInBtnWidth: CGFloat?
    
    let userAccount = UserManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userAccount.logoutUser(completion: {_ in})
        
        labelHeight = self.view.frame.size.height / 3
        labelWidth = self.view.frame.size.width - 100
        logInBtnHeight = self.view.frame.size.height / 10
        logInBtnWidth = self.view.frame.size.width / 3
        do {// verticallabel & its animation setup
            verticalLabel.alpha = 0
            verticalLabel.frame = CGRect(x: self.beginPosition.x, y: self.beginPosition.y, width: self.view.frame.size.width - 100, height: 150) // Start off-screen
            self.view.addSubview(verticalLabel)
            // Start the animation
            animateLabel()
            // tap to interrupt animation
            let tap = UITapGestureRecognizer(target: self, action: #selector(interruptAnimation))
            self.view.addGestureRecognizer(tap)
        }
        
        do {// continueBtn setup
            self.logInBtn.layer.cornerRadius = 30
            self.logInBtn.layer.borderWidth = 2
            self.logInBtn.backgroundColor = .white
            self.logInBtn.layer.borderColor = UIColor(red: 1, green: 0.625, blue: 0.625, alpha: 1).cgColor
            self.logInBtn.titleLabel?.textAlignment = .center
        }
    }
    
    func animateLabel() {
        // Animate the label
        print(self.endPosition)
        UIView.animate(withDuration: 2,
                       delay: 0,
                       options: [.curveLinear],
                       animations: {
            // Move the label to the bottom of the screen
            self.verticalLabel.frame = CGRect(x: self.endPosition.x, y: self.endPosition.y, width: self.labelWidth!, height: self.labelHeight!)
            self.verticalLabel.alpha = 1
        }, completion: nil)
    }
    
    @objc func interruptAnimation() {
        if let theLayer = self.verticalLabel.layer.presentation() {
            if theLayer.animationKeys() != nil {
                theLayer.removeAllAnimations()
                UIView.animate(withDuration: 0.2, animations: {
                    self.verticalLabel.frame = CGRect(x: self.endPosition.x, y: self.endPosition.y, width: self.labelWidth!, height: self.labelHeight!)
                    self.verticalLabel.alpha = 1
                })
            }
        }
    }
    

    @IBAction func continueBtnTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "IndexToMainNav", sender: self)
    }
    
}
