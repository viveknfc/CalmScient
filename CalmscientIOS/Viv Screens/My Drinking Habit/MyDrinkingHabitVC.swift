//
//  MyDrinkingHabitVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 10/12/24.
//

import UIKit

class MyDrinkingHabitVC: ViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var drinkCountCalculatorButton: LinearGradientButton!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedRowIndex : Int?
    
    var data: [(String, UIImage, [String], Bool)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "VivTableViewCell", bundle: nil), forCellReuseIdentifier: "VivCustomCell")

            // Set the delegate and data source
            tableView.delegate = self
            tableView.dataSource = self
        
        data = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? edata : sdata

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    @IBAction func drinkCountButtonPressed(_ sender: Any) {
        let backItem = UIBarButtonItem()
        backItem.title = "" // Set an empty string for the back button
        self.navigationItem.backBarButtonItem = backItem
        
        let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "DrinkingCountVC") as? DrinkingCountVC
        vc?.title = AppHelper.getLocalizeString(str: "Drink counts calculator")
        self.navigationController?.pushViewController(vc!, animated: true)
        
        
    }
    
    var edata = [
        ("Moderate drinking", UIImage(named: "check") ?? UIImage(), ["Always drink with the moderate drinking standard.", "Can effortlessly commit alcohol free plan for week or month.", "Can choose to drink or not even though people around you are drinking."], false),
        ("Moderate everyday drinking", UIImage(named: "check") ?? UIImage(), ["Always drink with the moderate drinking standard but struggles to have alcohol- free day.", "Drink daily as sleep aids or relaxation.", "Expect to have a drink after work or in the evening and get irritated or stressed when you can't have it."], false),
        ("Social / weekend binge drinking", UIImage(named: "check") ?? UIImage(), ["Casual drinking turns into doing things that you normal wouldn't do or that go against your judgement while you're sober, such as driving under alcohol influence.", "Often seek the mood-altering effects (the buzz) or using alcohol as a coping mechanism, sometimes in isolation.", "Get defensive when someone tries to limit your consumption or asks you to stop.", "Remember? Binge drinking is: Men - Up to 5 or more drinks within 2 hrs Women - Up to 4 or more drinks within 2 hrs."], false),
        ("Problematic drinking", UIImage(named: "check") ?? UIImage(), ["Drinking until drunk.", "Going to work drunk or drinking on the job.", "Driving while drunk or have driven while drunk.", "Getting in trouble with the law or being injured due to drinking.", "Doing something under the influence of alcohol that they would not otherwise do.", "Having problems at school, with social relationships, or with family members because of drinking.", "Using alcohol to decrease anxiety or sadness.", "Lying about or trying to hide drinking habits.", "Needing more alcohol to feel its effects.", "Feeling grouchy, resentful, or unreasonable when not drinking."], false)
    ]
    
    var sdata = [
        ("Consumo moderado", UIImage(named: "check") ?? UIImage(), ["Siempre bebes siguiendo el estándar de consumo moderado.", "Puedes comprometerte sin esfuerzo a un plan sin alcohol durante una semana o un mes.", "Puedes elegir beber o no, aunque las personas a tu alrededor estén bebiendo"], false),
        ("Consumo moderado diario", UIImage(named: "check") ?? UIImage(), ["Siempre bebes siguiendo el estándar de consumo moderado, pero me cuesta tener un día sin alcohol.", "Bebes a diario como ayuda para dormir o para relajarte.", "Anhelas tomar un trago después del trabajo o por la noche, y te irritas cuando no puedes hacerlo."], false),
        ("Consumo excesivo social / de fines de semana", UIImage(named: "check") ?? UIImage(), ["El consumo ocasional de alcohol te mueve a hacer cosas que normalmente no harías o que van en contra de tu juicio cuando estás sobrio, como conducir bajo los efectos del alcohol.", "A menudo buscas los efectos que alteran el estado de ánimo (el \("subidón")) o usas el alcohol como un mecanismo de afrontamiento, a veces en aislamiento.", "Te pones a la defensiva cuando alguien intenta limitar tu consumo o te pide que dejes de beber.", "¿Recuerdas? El consumo excesivo ocasional (binge drinking) es: Hombres: hasta 5 o más bebidas dentro de las 2 horas Mujeres: hasta 4 o más bebidas dentro de las 2 horas"], false),
        ("Consumo problemático", UIImage(named: "check") ?? UIImage(), ["Beber hasta emborracharse", "Ir a trabajar borracho o beber durante el trabajo", "Conducir bajo los efectos del alcohol o haber conducido borracho.", "Meterse en problemas con la ley o sufrir lesiones debido al consumo de alcohol.", "Hacer algo bajo la influencia del alcohol que no harían de otra manera.", "Tener problemas en la escuela, con las relaciones sociales o con los miembros de la familia a causa del consumo de alcohol.", "Usar el alcohol para disminuir la ansiedad o la tristeza.", "Mentir o intentar ocultar los hábitos de consumo de alcohol.", "Necesitar más alcohol para sentir sus efectos.", "Sentirse irritable, resentido o irrazonable cuando no se bebe."], false)
    ]
    
   

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VivCustomCell", for: indexPath) as! VivCustomTableViewCell

        // Get the data for the row
        let (heading, image, subtasks, isSelected) = data[indexPath.row]

        // Configure the cell
        cell.configureCell(heading: heading, image: image, subtasks: subtasks,isSelected: isSelected)

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


extension MyDrinkingHabitVC {
    
//MARK: - Button Actions
    
    @IBAction func yesBtnAction() {
        
        guard selectedRowIndex != nil else {
            
            let alertText = "Please select the stage that applies to you."
            
            showGeneralAlert(
                image: UIImage(named: "InfoIcon"),
                imageSize: CGSize(width: 60, height: 60),
                title: alertText,
                okButtonTitle: "Ok",
                okAction: {
                    print("Retry action triggered")
                },
                dismissAction: {
                    print("Dismiss action triggered")
                }
            )
            return
        }
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        
        let params: [String: Any] = [
                "patientId": userInfo.patientID,
                "entry": data[selectedRowIndex ?? 0].0,
                "plId": userInfo.patientLocationID,
                "clientId": userInfo.clientID,
                "entryType": "discovery_exercise"
                // Add other necessary parameters here
            ]

        print("the Yes Button in My Drinking Habit API call params", params)
        
        self.view.showToastActivity()
        
        APIService.AddJournalAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") {  [self] response in
            print(response)
            self.view.hideToastActivity()
            if let responseDict = response as? [String: Any],
               let responseMessage = responseDict["responseMessage"] as? String {
                print(responseMessage)
                self.showSuccessAlert(successContent: responseMessage, centreImage: nil, okButtonAction: {
                    
                })
            }

            
        }
        
    }
    
    @IBAction func nextBtnAction() {
         
        if selectedRowIndex == 0 {
            
            let backItem = UIBarButtonItem()
            backItem.title = "" // Set an empty string for the back button
            self.navigationItem.backBarButtonItem = backItem
            
            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "ModerateDrinkingVC") as? ModerateDrinkingVC
            vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        else if selectedRowIndex == 1 {
            
            let backItem = UIBarButtonItem()
            backItem.title = "" // Set an empty string for the back button
            self.navigationItem.backBarButtonItem = backItem
            
            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "Modarate2VC") as? Modarate2VC
            vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        else if selectedRowIndex == 2 {
            
            let backItem = UIBarButtonItem()
            backItem.title = "" // Set an empty string for the back button
            self.navigationItem.backBarButtonItem = backItem
            
            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "Modarate3VC") as? Modarate3VC
            vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        else if selectedRowIndex == 3 {
            
            let backItem = UIBarButtonItem()
            backItem.title = "" // Set an empty string for the back button
            self.navigationItem.backBarButtonItem = backItem
            
            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "Modarate4VC") as? Modarate4VC
            vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
            self.navigationController?.pushViewController(vc!, animated: true)
        } else {
            let alertText = "Please select the stage that applies to you."
            
            showGeneralAlert(
                image: UIImage(named: "InfoIcon"),
                imageSize: CGSize(width: 60, height: 60),
                title: alertText,
                okButtonTitle: "Ok",
                okAction: {
                    print("Retry action triggered")
                },
                dismissAction: {
                    print("Dismiss action triggered")
                }
            )
        }

        
    }
}
