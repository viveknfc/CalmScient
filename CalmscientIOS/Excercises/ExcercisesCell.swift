//
//  ExcercisesCell.swift
//  sample
//
//  Created by Krishna on 8/5/24.
//

import UIKit

class ExerciseCell: UICollectionViewCell {

    @IBOutlet weak var imageView: GradientImageView!
    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        setupGradient()
//                setupLabelBackground()
        self.configView()
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        label.textColor = .white
    }
    
    private func configView() {
        self.clipsToBounds = false
        self.backgroundColor = .systemBackground
        self.layer.cornerRadius = 10
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        self.layer.shadowRadius = 10
        self.layer.shadowOpacity = 0.2
    }
     
    
    private func setupGradient() {
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = imageView.bounds
            gradientLayer.colors = [
                UIColor.clear.cgColor,
                UIColor(white: 0, alpha: 0.6).cgColor,
                
            ]
            gradientLayer.locations = [0.0, 1.0]
            imageView.layer.addSublayer(gradientLayer)
        label.textColor = .white
        
        }

        private func setupLabelBackground() {
            label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            label.textColor = .white
            label.layer.cornerRadius = 5
            label.layer.masksToBounds = true
        }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update the gradient frame in case of cell resizing
        if let gradientLayer = imageView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = imageView.bounds
        }
    }

}


class GradientImageView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyGradient()
    }
    
    private func applyGradient() {
        // Remove existing gradient layers to avoid layering multiple gradients
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = bounds
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        
        layer.addSublayer(gradientLayer)
    }
}
