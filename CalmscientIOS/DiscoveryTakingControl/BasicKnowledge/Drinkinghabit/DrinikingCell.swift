//
//  DrinikingCell.swift
//  CalmscientIOS
//
//  Created by mac on 06/06/24.
//

import UIKit

class DrinikingCell: UITableViewCell {
    @IBOutlet var None_button: UIButton!
    @IBOutlet var lessthan2_button: UIButton!
    @IBOutlet var threetofive_button: UIButton!
    @IBOutlet var almost_button: UIButton!
    @IBOutlet var evryday_button: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
       
        None_button.layer.borderWidth = 0.5
//            button.layer.borderColor = UIColor.black.cgColor
        None_button.layer.cornerRadius = 10
        None_button.layer.borderColor = UIColor(red: 232/255, green: 231/255, blue: 244/255, alpha: 1).cgColor
        None_button.layer.shadowColor = UIColor.black.cgColor
        None_button.layer.shadowOffset = CGSize(width: 0, height: 1)
        None_button.layer.shadowOpacity = 0.1
        None_button.layer.shadowRadius = 1.0
        None_button.layer.masksToBounds = false
        
        lessthan2_button.layer.borderWidth = 0.5
//            button.layer.borderColor = UIColor.black.cgColor
        lessthan2_button.layer.cornerRadius = 10
        lessthan2_button.layer.borderColor = UIColor(red: 232/255, green: 231/255, blue: 244/255, alpha: 1).cgColor
        lessthan2_button.layer.shadowColor = UIColor.black.cgColor
        lessthan2_button.layer.shadowOffset = CGSize(width: 0, height: 1)
        lessthan2_button.layer.shadowOpacity = 0.1
        lessthan2_button.layer.shadowRadius = 1.0
        lessthan2_button.layer.masksToBounds = false
        
        threetofive_button.layer.borderWidth = 0.5
//            button.layer.borderColor = UIColor.black.cgColor
        threetofive_button.layer.cornerRadius = 10
        threetofive_button.layer.borderColor = UIColor(red: 232/255, green: 231/255, blue: 244/255, alpha: 1).cgColor
        threetofive_button.layer.shadowColor = UIColor.black.cgColor
        threetofive_button.layer.shadowOffset = CGSize(width: 0, height: 1)
        threetofive_button.layer.shadowOpacity = 0.1
        threetofive_button.layer.shadowRadius = 1.0
        threetofive_button.layer.masksToBounds = false
        
        almost_button.layer.borderWidth = 0.5
//            button.layer.borderColor = UIColor.black.cgColor
        almost_button.layer.cornerRadius = 10
        almost_button.layer.borderColor = UIColor(red: 232/255, green: 231/255, blue: 244/255, alpha: 1).cgColor
        almost_button.layer.shadowColor = UIColor.black.cgColor
        almost_button.layer.shadowOffset = CGSize(width: 0, height: 1)
        almost_button.layer.shadowOpacity = 0.1
        almost_button.layer.shadowRadius = 1.0
        almost_button.layer.masksToBounds = false
        
        evryday_button.layer.borderWidth = 0.5
//            button.layer.borderColor = UIColor.black.cgColor
        evryday_button.layer.cornerRadius = 10
        evryday_button.layer.borderColor = UIColor(red: 232/255, green: 231/255, blue: 244/255, alpha: 1).cgColor
        evryday_button.layer.shadowColor = UIColor.black.cgColor
        evryday_button.layer.shadowOffset = CGSize(width: 0, height: 1)
        evryday_button.layer.shadowOpacity = 0.1
        evryday_button.layer.shadowRadius = 1.0
        evryday_button.layer.masksToBounds = false
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func didClickOnAnswer(_ sender: UIButton) {
        resetAllButtons()
        sender.setTitleColor(UIColor.white, for: .normal)
        sender.setImage(self.imageFromColor(color: UIColor(named: "6E6BB3ColorOnly")!), for: .normal)

    }
    
    private func resetAllButtons() {
        for buttonElement in [None_button,lessthan2_button,threetofive_button,almost_button,evryday_button] {
            buttonElement?.setTitleColor(UIColor(named: "One424242Color"), for: .normal)
            buttonElement?.setImage(self.imageFromColor(color: UIColor.white), for: .normal)
        }
    }
    
    func imageFromColor(color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

