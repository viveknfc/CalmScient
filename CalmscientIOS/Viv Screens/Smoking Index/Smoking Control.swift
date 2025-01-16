//
//  Smoking Control.swift
//  CalmscientIOS
//
//  Created by NFC User on 28/11/24.
//

import Foundation
import UIKit

class SmokingControl: ViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var leftBox: UIView!
    @IBOutlet weak var rightBox: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var resourceTableView: UITableView!
    
    
    override func viewDidLoad() {
        leftBox.layer.cornerRadius = 12
        leftBox.layer.masksToBounds = true
        
        rightBox.layer.cornerRadius = 12
        rightBox.layer.masksToBounds = true
        
        tableView.register(UINib(nibName: "IndexBasicTableCell", bundle: nil), forCellReuseIdentifier: "smokingBasicCell")

        resourceTableView.register(UINib(nibName: "SomkingIndexResourceCell", bundle: nil), forCellReuseIdentifier: "SmokingResourceCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        resourceTableView.delegate = self
        resourceTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    let data = [("Basic knowledge", UIImage(named: "check") ?? UIImage()), ("Make a plan", UIImage(named: "check") ?? UIImage()), ("Stay focused", UIImage(named: "check") ?? UIImage()), ("My progress", UIImage(named: "check") ?? UIImage())]
    
    let resourceData = [("Work your strengths", "Do something you're good at to build self-confidence, then tackle a tougher task.", UIImage(named: "Mask") ?? UIImage()), ("Breathing exercises", "Let’s use breathing exercises to support your journey. They help reduce stress and cravings, and provide a calming distraction..", UIImage(named: "breathingTechnique") ?? UIImage()), ("Managing anxiety course", "Anxiety can trigger drinking and smoking, but healthy coping strategies help you to stay strong", UIImage(named: "img1") ?? UIImage()), ("Screenings", "Let’s set a goal to screen for depression, anxiety, and alcohol and smoking regularly, as these can support your success", UIImage(named: "Screening_Cell") ?? UIImage())]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return data.count
        } else if tableView == self.resourceTableView {
            return resourceData.count
        }
        return 0

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
                  let cell = tableView.dequeueReusableCell(withIdentifier: "smokingBasicCell", for: indexPath) as! SmokingBasicIndexTableCell
                  
                  let content = data[indexPath.row].0
                  let image = data[indexPath.row].1
                  
                  cell.cellContentText.text = content
                  if indexPath.row == 0 {
                      cell.configureCell(isActive: true)
                      cell.ticckImage.image = image
                  } else {
                      cell.configureCell(isActive: false)
                  }
                  
                  return cell
              } else if tableView == self.resourceTableView {
                  let cell = tableView.dequeueReusableCell(withIdentifier: "SmokingResourceCell", for: indexPath) as! SmokingIndexResourceTableViewCell
                  
                  let content = resourceData[indexPath.row].0
                  let desc = resourceData[indexPath.row].1
                  let image = resourceData[indexPath.row].2
                  
                  cell.headLabel.text = content
                  cell.desc.text = desc
                  cell.rightImage.image = image
                  
                  return cell
              }
              
              return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableView {
                   return 60
               } else if tableView == self.resourceTableView {
                   return 150 // Default row height
               }
               return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10 // Adjust as needed
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10 // Adjust as needed
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == self.tableView {
            if indexPath.row == 0 {
                print("first row clicked")
                let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
                let vc = next.instantiateViewController(withIdentifier: "SmokingBasicVc") as? SmokingBasicVc
                vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
                self.navigationController?.pushViewController(vc!, animated: true)
                
            }
        }
        
    }
    
}

