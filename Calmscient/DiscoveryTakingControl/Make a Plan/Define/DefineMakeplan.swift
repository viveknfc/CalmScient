//
//  DefineMakeplan.swift
//  CalmscientIOS
//
//  Created by mac on 25/06/24.
//

import Foundation
import UIKit
@available(iOS 16.0, *)
class DefineMakeplan: ViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    //    @IBOutlet weak var alcholgoalView: UIView!
    //    @IBOutlet weak var alcholnowView: UIView!
    //    @IBOutlet weak var drinkgoalView: UIView!`
    //    @IBOutlet weak var drinknowView: UIView!
    //    @IBOutlet weak var basicKnowledge: UIButton!
    //    @IBOutlet weak var labelsContainerView: UIView!
    
    var button_name = ["To improve my health","To improve my relationships","To avoid hangovers","To do better at work or in school", "To save money","To lose weight or get fit","To avoid more serious problems","To meet my own personal standards"]
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.dataSource = self
                tableView.delegate = self

                tableView.register(UINib(nibName: "DefineCell", bundle: nil), forCellReuseIdentifier: "DefineCell")
        tableView.register(UINib(nibName: "FactorCell", bundle: nil), forCellReuseIdentifier: "FactorCell")
        tableView.register(UINib(nibName: "DefineMakeCell", bundle: nil), forCellReuseIdentifier: "DefineMakeCell")
        tableView.register(UINib(nibName: "MindCell", bundle: nil), forCellReuseIdentifier: "MindCell")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 4
    }
   
    
    
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            switch section {
            case 0: return 1
            
            default:
                return 1
            }
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefineMakeCell", for: indexPath) as! DefineMakeCell
//                    cell.leftBox.layer.cornerRadius = 10
//                    cell.rightBox.layer.cornerRadius = 10
            
                cell.selectionStyle = .none
                // Configure the cell as needed
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefineCell", for: indexPath) as! DefineCell
//                    cell.leftBox.layer.cornerRadius = 10
//                    cell.rightBox.layer.cornerRadius = 10
            
                cell.selectionStyle = .none
                // Configure the cell as needed
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FactorCell", for: indexPath) as! FactorCell
//                    cell.leftBox.layer.cornerRadius = 10
//                    cell.rightBox.layer.cornerRadius = 10
            
                cell.selectionStyle = .none
                // Configure the cell as needed
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "MindCell", for: indexPath) as! MindCell
//                    cell.leftBox.layer.cornerRadius = 10
//                    cell.rightBox.layer.cornerRadius = 10
                cell.track_btn.addTarget(self, action: #selector(trackButtonTapped(_:)), for: .touchUpInside)
                cell.selectionStyle = .none
                cell.quit_btn.addTarget(self, action: #selector(quitButtonTapped(_:)), for: .touchUpInside)

                // Configure the cell as needed
                return cell
            
            default:
                return UITableViewCell()
            }
        }
    

        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            switch indexPath.section {
            case 1,2:
                return 295 // 7 buttons * 45 height + spacing
            case 0:
                return 395 // 7 buttons * 45 height + spacing
            
            default:
                return UITableView.automaticDimension
            }
        }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if(indexPath.section == 2){
//            if(indexPath.row == 0){
//                let next = UIStoryboard(name: "Basicknowledge", bundle: nil)
//                let vc = next.instantiateViewController(withIdentifier: "Basicknowledge") as? Basicknowledge
//                vc?.title = "Make a Plan"
//                self.navigationController?.pushViewController(vc!, animated: true)
//            }
//            if(indexPath.row == 1){
//                let next = UIStoryboard(name: "Basicknowledge", bundle: nil)
//                let vc = next.instantiateViewController(withIdentifier: "Basicknowledge") as? Basicknowledge
//                vc?.title = "Make a Plan"
//                self.navigationController?.pushViewController(vc!, animated: true)
//            }
//           
//            
//               }
//        if(indexPath.section == 3){
//          //  if(indexPath.row == 0){
//                let next = UIStoryboard(name: "MonthlyDrinksCountViewController", bundle: nil)
//                let vc = next.instantiateViewController(withIdentifier: "MonthlyDrinksCountViewController") as? MonthlyDrinksCountViewController
//                vc?.title = "Make a Plan"
//                self.navigationController?.pushViewController(vc!, animated: true)
//           // }
//        }
    }
    @objc func trackButtonTapped(_ sender: UIButton) {
        // Identify the cell and get the corresponding data
        guard let cell = sender.superview?.superview as? MindCell,
              let indexPath = tableView.indexPath(for: cell) else { return }
        
        // Handle the button tap, using the indexPath if needed
        print("Track button tapped at row \(indexPath.row)")
        let next = UIStoryboard(name: "MonthlyDrinksCountViewController", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "MonthlyDrinksCountViewController") as? MonthlyDrinksCountViewController
        vc?.title = AppHelper.getLocalizeString(str: "Make a plan")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @objc func quitButtonTapped(_ sender: UIButton) {
        // Identify the cell and get the corresponding data
        guard let cell = sender.superview?.superview as? MindCell,
              let indexPath = tableView.indexPath(for: cell) else { return }
       
        let next = UIStoryboard(name: "QuitViewController", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "QuitViewController") as? QuitViewController
        vc?.title = AppHelper.getLocalizeString(str: "Make a plan")
        self.navigationController?.pushViewController(vc!, animated: true)
    }

}
