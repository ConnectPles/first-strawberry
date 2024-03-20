//
//  IndexViewController.swift
//  ConnectPle
//
//  Created by Nolan Chen on 2/16/24.
//

import UIKit

class IndexViewController: UIViewController {

    @IBOutlet weak var verticalLabel: UILabel!
    @IBOutlet weak var continueBtn: UIButton!
    
    
    let beginPosition = INDEX_VERTICAL_LABEL_BEGIN_POSITION
    let endPosition = INDEX_VERTICAL_LABEL_END_POSITION
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {// verticallabel & its animation setup
            verticalLabel.alpha = 0
            verticalLabel.frame = CGRect(x: self.beginPosition.x, y: self.beginPosition.y, width: self.view.frame.size.width - 100, height: 150) // Start off-screen
            self.view.addSubview(verticalLabel)
            // Start the animation
            animateLabel()
            // tap to interrupt animation
            let tap = UITapGestureRecognizer(target: self, action: #selector(interruptAnimation))
            view.addGestureRecognizer(tap)
        }
        do {// continueBtn setup
            self.continueBtn.titleLabel?.textAlignment = .center
            self.continueBtn.layer.borderWidth = 2
            self.continueBtn.layer.borderColor = UIColor.systemPurple.cgColor
            self.continueBtn.layer.cornerRadius = 10
        }
    }
    
    func animateLabel() {
        // Calculate the end position of the label

        // Animate the label
        UIView.animate(withDuration: 1, // Duration in seconds
                       delay: 0,
                       options: [.curveLinear],
                       animations: {
            // Move the label to the bottom of the screen
            self.verticalLabel.frame = CGRect(x: self.endPosition.x, y: self.endPosition.y, width: self.verticalLabel.frame.size.width, height: self.verticalLabel.frame.size.height)
            self.verticalLabel.alpha = 1
        }, completion: nil)
    }
    
    @objc func interruptAnimation() {
        if let theLayer = self.verticalLabel.layer.presentation() {
            let theFrame = theLayer.frame
            theLayer.removeAllAnimations()
            UIView.animate(withDuration: 0.2, animations: {
                self.verticalLabel.frame = CGRect(x: self.endPosition.x, y: self.endPosition.y, width: theFrame.size.width, height: theFrame.size.height)
                self.verticalLabel.alpha = 1 // Ensure the label is fully visible
            })
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
