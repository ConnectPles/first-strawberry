//
//  IndexViewController.swift
//  ConnectPle
//
//  Created by Nolan Chen on 2/16/24.
//

import UIKit

class IndexViewController: UIViewController {

    @IBOutlet weak var bgImage: UIImageView!
    let rollingLabel = UILabel()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // Setup the label with your desired text
        rollingLabel.text = "Connect Couples."
        rollingLabel.numberOfLines = 2 // Allows for multiple lines
        rollingLabel.frame = CGRect(x: 20, y: -10, width: self.view.frame.size.width - 40, height: 200) // Start off-screen
        self.view.addSubview(rollingLabel)

        // Start the animation
        animateLabel()
    }
    
    func animateLabel() {
        // Calculate the end position of the label
        let endPosition = 0 + rollingLabel.frame.size.height

        // Animate the label
        UIView.animate(withDuration: 3, // Duration in seconds
                       delay: 0,
                       options: [.curveLinear],
                       animations: {
            // Move the label to the bottom of the screen
            self.rollingLabel.frame = CGRect(x: 20, y: endPosition, width: self.rollingLabel.frame.size.width, height: self.rollingLabel.frame.size.height)
        }, completion: nil)
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
