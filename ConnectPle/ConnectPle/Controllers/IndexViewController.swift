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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            self.logInBtn.layer.cornerRadius = 10
            self.logInBtn.layer.borderWidth = 2
            self.logInBtn.layer.borderColor = UIColor(red: 1, green: 0.625, blue: 0.625, alpha: 1).cgColor
            self.logInBtn.titleLabel?.textAlignment = .center

            let layer0 = CAGradientLayer()
            layer0.colors = [
              UIColor(red: 0.963, green: 0.872, blue: 0.872, alpha: 1).cgColor,
              UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor,
              UIColor(red: 0.988, green: 0.894, blue: 0.894, alpha: 1).cgColor
            ]
            layer0.locations = [0, 0.48, 0.98]
            layer0.startPoint = CGPoint(x: 0.25, y: 0.5)
            layer0.endPoint = CGPoint(x: 0.75, y: 0.5)
            layer0.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 1, b: 0, c: 0, d: 6.25, tx: 0, ty: -2.62))
            layer0.bounds = self.logInBtn.bounds.insetBy(dx: -0.5*self.logInBtn.bounds.size.width, dy: -0.5*self.logInBtn.bounds.size.height)
            layer0.position = self.logInBtn.center
            self.logInBtn.layer.addSublayer(layer0)
            
            let layer1 = CALayer()
            layer1.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2).cgColor
            layer1.bounds = self.logInBtn.bounds
            layer1.position = self.logInBtn.center
            self.logInBtn.layer.addSublayer(layer1)
            
        }
    }
    
    func animateLabel() {
        // Calculate the end position of the label

        // Animate the label
        print(self.endPosition)
        UIView.animate(withDuration: 2, // Duration in seconds
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
            theLayer.removeAllAnimations()
            UIView.animate(withDuration: 0.2, animations: {
                self.verticalLabel.frame = CGRect(x: self.endPosition.x, y: self.endPosition.y, width: self.labelWidth!, height: self.labelHeight!)
                self.verticalLabel.alpha = 1 // Ensure the label is fully visible
            })
        }
    }
    

    @IBAction func continueBtnTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "IndexToMainNav", sender: self)
    }
    
}
