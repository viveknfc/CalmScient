//
//  QuestionnairesVC.swift
//  HealthScreeningApp
//
//  Created by KA on 23/03/24.
//

import UIKit

class QuestionnairesVC: UIViewController {
    
    @IBOutlet weak var questionTable: UITableView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var question1Label: UILabel!
    let optionsList = ["Not at all", "Several days", "More than half of the days", "Nearly everyday"]

    override func viewDidLoad() {
        super.viewDidLoad()
        questionTable.register(UINib(nibName: "QuestionCell", bundle: nil), forCellReuseIdentifier: "QuestionCell")
    }
    override func viewWillAppear(_ animated: Bool) {
        setupLanguage()
    }

    func setupLanguage() {
        
            let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            
            if languageId == 1 {
                UserDefaults.standard.set("en", forKey: "Language")
            } else if languageId == 2 {
                UserDefaults.standard.set("es", forKey: "Language")
            }
       
        titleLabel.text = AppHelper.getLocalizeString(str:"Over the last 2 weeks, how often have you been bothered by the following problems?")
        question1Label.text = AppHelper.getLocalizeString(str:"1. Feeling nervous, anxious or on edge")
    //        change at line 48, 49,
        }
}


extension QuestionnairesVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:QuestionCell = self.questionTable.dequeueReusableCell(withIdentifier: "QuestionCell") as! QuestionCell
        let data = optionsList[indexPath.row]
        cell.optionLbl.text = data
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = bgColorView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! QuestionCell
        cell.cornerView.backgroundColor = UIColor(named: "ApptColor")
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! QuestionCell
        cell.cornerView.backgroundColor = UIColor.white
    }
}
