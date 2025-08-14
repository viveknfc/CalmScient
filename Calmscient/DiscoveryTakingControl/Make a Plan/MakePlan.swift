//
//  MakePlan.swift
//  CalmscientIOS
//
//  Created by mac on 17/06/24.
//

import Foundation
import UIKit
@available(iOS 16.0, *)
class MakePlan: ViewController,UITableViewDelegate,UITableViewDataSource {
    var previousSelectedIndexPath: IndexPath?
    var previousSelectedIndexPath1: IndexPath?
    @IBOutlet weak var tableView: UITableView!
    //    @IBOutlet weak var alcholgoalView: UIView!
    //    @IBOutlet weak var alcholnowView: UIView!
    //    @IBOutlet weak var drinkgoalView: UIView!`
    //    @IBOutlet weak var drinknowView: UIView!
    //    @IBOutlet weak var basicKnowledge: UIButton!
    //    @IBOutlet weak var labelsContainerView: UIView!
    
    var button_name = ["To improve my health","To improve my relationships","To avoid hangovers","To do better at work or in school", "To save money","To lose weight or get fit","To avoid more serious problems","To meet my own personal standards"]
    var cons_arr = ["I'd need another way to unwind","It helps me feel more at ease socially","I wouldn't fit in with some of my friends","Change can be hard"]
    
    var button_namespanish = ["Mejorar mi salud", "Mejorar mis relaciones", "Evitar resacas", "Rendir mejor en el trabajo o en la escuela", "Ahorrar dinero", "Perder peso o ponerme en forma", "Evitar problemas más graves", "Cumplir mis propios estándares personales"];
    var cons_arrspanish = ["Necesitaría otra forma de relajarme", "Me ayuda a sentirme más cómodo socialmente", "No encajaría con algunos de mis amigos", "El cambio puede ser difícil"];

    
    var prosText : String  = ""
    var prosTextfieldText : String  = ""
    var consText : String  = ""
    var consTextfieldText : String  = ""
    var journalEntry: [[String: String]] = []
    var tableSelectedRow:[Int:Int] = [:]
    override func viewDidLoad() {
       
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "ChangeCell", bundle: nil), forCellReuseIdentifier: "ChangeCell")
        tableView.register(UINib(nibName: "ProsCell", bundle: nil), forCellReuseIdentifier: "ProsCell")
        tableView.register(UINib(nibName: "ProsOthers", bundle: nil), forCellReuseIdentifier: "ProsOthers")
        tableView.register(UINib(nibName: "TellUsCell", bundle: nil), forCellReuseIdentifier: "TellUsCell")
        
        
        tableView.register(CustomHeaderView.self, forHeaderFooterViewReuseIdentifier: "CustomHeaderView")
        
        //        basicKnowledge.layer.borderWidth = 1;
        //        basicKnowledge.layer.borderColor = UIColor(red: 110/255, green: 107/255, blue: 179/255, alpha: 1).cgColor
        //        basicKnowledge.tintColor = UIColor(red: 110/255, green: 107/255, blue: 179/255, alpha: 1)
        //        basicKnowledge.layer.cornerRadius = 10;
        
        updateView()
        self.navigationController?.isNavigationBarHidden = false
        
        //        tableView.register(UINib(nibName: "MyMedicalRecordsCell", bundle: nil), forCellReuseIdentifier: "MyMedicalRecordsCell")
        //        tableView.dataSource = self
        //        tableView.delegate = self
        //        self.navigationController?.navigationBar.isHidden = false
        //        self.navigationItem.title = "Discovery"
        // Do any additional setup after loading the view.
    }
    
    @objc func clicked1(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func clicked(_ sender: UIButton) {
        
        
        let next = UIStoryboard(name: "DefineMakeplan", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "DefineMakeplan") as? DefineMakeplan
        vc?.title =  AppHelper.getLocalizeString(str: "Make a plan")
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    @objc func yesclicked(_ sender: UIButton) {
        tableView.reloadData()
        self.view.showToastActivity()
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        saveCourseJournalEntry(plId: userInfo.patientLocationID, clientId: userInfo.clientID,  bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
            switch result {
            case .success(let data):
                // Convert data to JSON object and print it
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async {
                            print("saveCourseJournalEntry===\(json)")
                            self.view.hideToastActivity()
                        }
                        
                    } else {
                        print("Unable to convert data to JSON")
                    }
                } catch {
                    print("Error converting data to JSON: \(error)")
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
        
        
    }
    func updateView() {
        
        //        drinkingContainer.isHidden = customSegmentedControl.selectedIndex != 0
        //        smokingContainer.isHidden = customSegmentedControl.selectedIndex != 1
    }
    
    func saveCourseJournalEntry(plId: Int,  clientId: Int, bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
        
        guard let url = URL(string: "\(baseURLString)patients/api/v1/patientDetails/saveCourseJournalEntry") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        
        
        // Define the JSON payload
        let payload: [String: Any] = [
            "patientId": plId,
            "clientId": clientId,
            "journalEntry": journalEntry
        ]
        
        print("payload\(payload)")
        // Convert the payload to JSON data
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            request.httpBody = jsonData
            //print(jsonData)
        } catch {
            print("Error converting payload to JSON: \(error)")
            completion(.failure(error))
            return
        }
        
        // Create the URLSession data task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error with request: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            // If needed, handle the response here
            completion(.success(data))
        }
        
        // Start the data task
        task.resume()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return button_name.count
        case 2: return 1
        case 3: return cons_arr.count
        case 4: return 1
        case 5: return 1
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChangeCell", for: indexPath) as! ChangeCell
            cell.selectionStyle = .none
            return cell
        case 1:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ProsCell", for: indexPath) as! ProsCell
            let selectedLanguageID = UserDefaults.standard.integer(forKey: "SelectedLanguageID")

            if selectedLanguageID == 1 {
                    // English
                    cell.label.text = button_name[indexPath.row]
                } else {
                    
                    cell.label.text = button_namespanish[indexPath.row]
                }
            
                   // cell.label.text = button_name[indexPath.row]
                    
                    if tableSelectedRow[indexPath.section] != nil && indexPath.row == tableSelectedRow[indexPath.section] {
                        cell.main_view.backgroundColor = UIColor(named: "AppBorderColor")
                        cell.label.textColor = UIColor(named: "appointmentBackgroundcolor")
                    } else {
                        cell.main_view.backgroundColor = UIColor.systemBackground
                        cell.label.textColor = UIColor(named: "424242Color")
                    }
                    cell.selectionStyle = .none
                    return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProsOthers", for: indexPath) as! ProsOthers
            //                    cell.leftBox.layer.cornerRadius = 10
            //                    cell.rightBox.layer.cornerRadius = 10
            //                    cell.label.text = button_name[indexPath.row]
            if let prosText = cell.label.text, !prosText.isEmpty {
                journalEntry.append(["entry": prosText])
            }
            //  prosTextfieldText = cell.label.text
            cell.otherLabel.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Others" : "Otros"
            cell.selectionStyle = .none
            print(journalEntry)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProsCell", for: indexPath) as! ProsCell
           
            let selectedLanguageID = UserDefaults.standard.integer(forKey: "SelectedLanguageID")

            if selectedLanguageID == 1 {
                    // English
                cell.label.text = cons_arr[indexPath.row]
                } else {
                    
                    cell.label.text = cons_arrspanish[indexPath.row]
                }
            if tableSelectedRow[indexPath.section] != nil && indexPath.row == tableSelectedRow[indexPath.section] {
                cell.main_view.backgroundColor = UIColor(named: "AppBorderColor")
                cell.label.textColor = UIColor(named: "appointmentBackgroundcolor")
            } else {
                cell.main_view.backgroundColor = UIColor.systemBackground
                cell.label.textColor = UIColor(named: "424242Color")
            }
            cell.selectionStyle = .none
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProsOthers", for: indexPath) as! ProsOthers
            //                    cell.leftBox.layer.cornerRadius = 10
            //                    cell.rightBox.layer.cornerRadius = 10
            //                    cell.label.text = button_name[indexPath.row]
            if let consText = cell.label.text, !consText.isEmpty {
                journalEntry.append(["entry": consText])
            }
            cell.otherLabel.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Others" : "Otros"
            cell.selectionStyle = .none
            print(journalEntry)
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TellUsCell", for: indexPath) as! TellUsCell
            //                    cell.leftBox.layer.cornerRadius = 10
            //                    cell.rightBox.layer.cornerRadius = 10
            //                    cell.label.text = button_name[indexPath.row]
            cell.yesButton.addTarget(self, action: #selector(yesclicked), for: .touchUpInside)
            cell.quit_btn.addTarget(self, action: #selector(clicked), for: .touchUpInside)
            cell.track_btn.addTarget(self, action: #selector(clicked1), for: .touchUpInside)
            
            cell.selectionStyle = .none
            // Configure the cell as needed
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 2 || section == 4 || section == 4 {
            return nil // Hide headers for sections 2 and 3
        }
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CustomHeaderView") as! CustomHeaderView
        
        switch section {
        case 2:
            header.setText(UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Alcohol free days" : "Días sin alcohol.")
        case 1:
            header.setText(UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "pros:" : "Ventajas:")
        case 3:
            header.setText(UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "cons:" : "Contras:")
        default:
            header.setText("")
        }
        return header
    }
    
    // Set the height for the header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0;
        case 1,3:
            return 35
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 173 // 7 buttons * 45 height + spacing
        case 1,3:
            return 55 // Adjust the height as needed
        case 2,4:
            return 185
        case 5:
            return 282
        default:
            return UITableView.automaticDimension
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
                
                if indexPath.section == 1 {
                    tableSelectedRow[1] = indexPath.row
                    let names = button_name[indexPath.row] as String
                    print("Prosnames===\(names)")
                    prosText = names
                    
                    // Remove the previous entry from journalEntry
                    if let previousIndexPath = previousSelectedIndexPath {
                        if let previousCell = tableView.cellForRow(at: previousIndexPath) {
                            journalEntry.removeAll { $0["entry"] == button_name[previousIndexPath.row] }
                           // tableView.reloadRows(at: [previousIndexPath], with: .none)
                        }
                    }
                    
                   
                    journalEntry.append(["entry": names])
                    previousSelectedIndexPath = indexPath
                    tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
                    
                    print(journalEntry)
                }
                if indexPath.section == 3 {
                    tableSelectedRow[3] = indexPath.row
                    let names1 = cons_arr[indexPath.row] as String
                    print("Consnames===\(names1)")
                    consText = names1
                    
                    // Remove the previous entry from journalEntry
                    if let previousIndexPath1 = previousSelectedIndexPath1 {
                        if let previousCell = tableView.cellForRow(at: previousIndexPath1) {
                            journalEntry.removeAll { $0["entry"] == cons_arr[previousIndexPath1.row] }
                        }
                    }
                    
                    // Add the new entry to journalEntry
                    journalEntry.append(["entry": names1])
                    
                    tableView.reloadSections(IndexSet(integer: 3), with: .automatic)
                    previousSelectedIndexPath1 = indexPath
                    print(journalEntry)
                }
                
                if(indexPath.section == 2){
                    if(indexPath.row == 0){
                        let next = UIStoryboard(name: "Basicknowledge", bundle: nil)
                        let vc = next.instantiateViewController(withIdentifier: "Basicknowledge") as? Basicknowledge
                        vc?.title =  AppHelper.getLocalizeString(str: "Make a plan")
                        self.navigationController?.pushViewController(vc!, animated: true)
                    }
                    if(indexPath.row == 1){
                        let next = UIStoryboard(name: "Basicknowledge", bundle: nil)
                        let vc = next.instantiateViewController(withIdentifier: "Basicknowledge") as? Basicknowledge
                        vc?.title =  AppHelper.getLocalizeString(str: "Make a plan")
                        self.navigationController?.pushViewController(vc!, animated: true)
                    }
                }
            
    }
    
}
