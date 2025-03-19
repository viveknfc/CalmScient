//
//  MySmokingHabitVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 12/03/25.
//

import UIKit

class MySmokingHabitVC: ViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var smokingTableView: UITableView!
    
    var selectedRowIndex : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        smokingTableView.register(UINib(nibName: "VivTableViewCell", bundle: nil), forCellReuseIdentifier: "VivCustomCell")

            // Set the delegate and data source
        smokingTableView.delegate = self
        smokingTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = smokingTableView.indexPathForSelectedRow {
            smokingTableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    var data = [
        ("Thinking about quitting", UIImage(named: "check") ?? UIImage(), ["You are considering it but haven't made a decision yet.\n\nThat's perfectly ok! We will guide you through the benefits of quitting smoking, and then you can decide if you'd like to create a plan for quitting.\nMove to Make a plan."], false),
        ("Getting ready to quit", UIImage(named: "check") ?? UIImage(), ["You've decided to quit smoking.\n\nGreat decision! We will guide you on how to create a solid plan and help you stay focused on your journey.\nMove to Make a plan."], false),
        ("Quitting", UIImage(named: "check") ?? UIImage(), ["You've already started or set a date to quit smoking.\n\nThat's great! We will help you create a strategic plan and stay focused on your goal.\nMove to Make a plan."], false),
        ("Staying smoke-free", UIImage(named: "check") ?? UIImage(), ["You're focusing on avoiding relapse and keeping up your progress.\n\nThat's fantastic. It's important not to let your guard down. We will be here to support you to stay strong.\nMove to Make a plan to register the day you started quitting smoking, then you can use Stay focused."], false)
    ]

    
    @IBAction func yesButtonPressede(_ sender: Any) {
    }
    
    
    @IBAction func completeButtonPresseed(_ sender: Any) {
    }
    
    //MARK: - Table Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VivCustomCell", for: indexPath) as! VivCustomTableViewCell

        // Get the data for the row
        let (heading, image, subtasks, isSelected) = data[indexPath.row]

        // Configure the cell
        cell.configureCell1(heading: heading, image: image, subtasks: subtasks,isSelected: isSelected)

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8 // Adjust as needed
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8 // Adjust as needed
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("table row selected")
        selectedRowIndex = indexPath.row
        
        for (i, _) in data.enumerated() {
            if i == indexPath.row {
                print(data[i].3)
                data[i].3 = true
            }
            else{
                data[i].3 = false
            }
        }
        
        DispatchQueue.main.async {
            tableView.reloadData()
        }
        
    }

    
    


}
