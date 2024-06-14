//
//  DarkenedImageView.swift
//  ConnectPle
//
//  Created by Nolan Chen on 6/12/24.
//

import UIKit

class DarkenedImageView: UIImageView {
    
    var overlayImageView: UIImageView!
    var activityIndicator: UIActivityIndicatorView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Create and configure the overlay image view
        overlayImageView = UIImageView(frame: self.bounds)
        overlayImageView.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Semi-transparent black
        overlayImageView.contentMode = .scaleToFill
        self.addSubview(overlayImageView)
        
        // Create and configure the activity indicator
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.center
        activityIndicator.color = THEME_COLOR
        activityIndicator.startAnimating()
        self.addSubview(activityIndicator)
    }
    
    func showLoading() {
        self.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoading() {
        self.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    // Ensure this view intercepts all touch events
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return true
    }
}
