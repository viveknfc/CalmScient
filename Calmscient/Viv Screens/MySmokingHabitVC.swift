//
//  MySmokingHabitVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 12/03/25.
//

import UIKit

class MySmokingHabitVC: ViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var smokingTableView: UITableView!
    @IBOutlet weak var completeButton: CapsuleButton1!
    
    var selectedRowIndex : Int?
    var sectionID6: Int?
    
    var data: [(String, UIImage, [String], Bool)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        smokingTableView.register(UINib(nibName: "VivTableViewCell", bundle: nil), forCellReuseIdentifier: "VivCustomCell")

            // Set the delegate and data source
        smokingTableView.delegate = self
        smokingTableView.dataSource = self
        // Do any additional setup after loading the view.
        
        data = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? edata : sdata
        
        let selectedLanguageID = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
        let title = selectedLanguageID == 1 ? "Complete" : "Finalizar"
        completeButton.setTitle(title, for: .normal)
        completeButton.titleLabel?.font = UIFont(name: Fonts().lexendLight, size: 14)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = smokingTableView.indexPathForSelectedRow {
            smokingTableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    var edata = [
        ("Thinking about quitting", UIImage(named: "check") ?? UIImage(), ["You are considering it but haven't made a decision yet.\n\nThat's perfectly ok! We will guide you through the benefits of quitting smoking, and then you can decide if you'd like to create a plan for quitting.\nMove to Make a plan."], false),
        ("Getting ready to quit", UIImage(named: "check") ?? UIImage(), ["You've decided to quit smoking.\n\nGreat decision! We will guide you on how to create a solid plan and help you stay focused on your journey.\nMove to Make a plan."], false),
        ("Quitting", UIImage(named: "check") ?? UIImage(), ["You've already started or set a date to quit smoking.\n\nThat's great! We will help you create a strategic plan and stay focused on your goal.\nMove to Make a plan."], false),
        ("Staying smoke-free", UIImage(named: "check") ?? UIImage(), ["You're focusing on avoiding relapse and keeping up your progress.\n\nThat's fantastic. It's important not to let your guard down. We will be here to support you to stay strong.\nMove to Make a plan to register the day you started quitting smoking, then you can use Stay focused."], false)
    ]
    
    var sdata = [
            ("Está pensando en dejar de fumar", UIImage(named: "check") ?? UIImage(), ["¡Está perfectamente bien! Te guiaremos para que veas los beneficios de dejar de fumar, y luego podrás decidir si deseas crear un plan para dejarlo. \nIr a Crear un plan."], false),
            ("Preparándose para dejar de fumar", UIImage(named: "check") ?? UIImage(), ["Has decidido dejar de fumar.\n\n¡Excelente decisión! Te guiaremos para que puedas crear un plan sólido y te ayudaremos a mantenerte enfocado en tu camino.\nIr a Crear un plan."], false),
            ("Dejar de fumar", UIImage(named: "check") ?? UIImage(), ["Ya has comenzado o ya tienes una fecha para dejar de fumar.\n\nTe ayudaremos a crear un plan estratégico y a mantenerte enfocado en tu objetivo.\nIr a Crear un plan."], false),
            ("Permanecer libre de humo", UIImage(named: "check") ?? UIImage(), ["Te estás enfocando en evitar recaídas y mantener tu progreso.\n\nEso es fantástico. Es importante no bajar la guardia. Estaremos aquí para apoyarte y Eduarte a mantenerte firme.\nIr a Crear un plan para registrar el día en que comenzaste a dejar de fumar, luego podrás usar la opción Mantente enfocado."], false)
        ]

    
    @IBAction func yesButtonPressede(_ sender: Any) {
        
        guard selectedRowIndex != nil else {
            
            let alertText = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Please select the stage that applies to you." : "Por favor, seleccione la etapa que le corresponde"
            
            showGeneralAlert(
                image: UIImage(named: "InfoIcon"),
                imageSize: CGSize(width: 60, height: 60),
                title: alertText,
                okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Specify the desired format
        let currentDate = Date()
        let formattedDate = dateFormatter.string(from: currentDate)
        
        let params: [String: Any] = [
                "patientId": userInfo.patientID,
                "entry": data[selectedRowIndex ?? 0].0,
                "plId": userInfo.patientLocationID,
                "clientId": userInfo.clientID,
                "entryType": "discovery_exercise",
                "createdAt": formattedDate
                // Add other necessary parameters here
            ]

        print("the Yes Button in My Smoking Habit API call params", params)
        
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
    
    
    @IBAction func completeButtonPresseed(_ sender: Any) {
        
        guard selectedRowIndex != nil else {
            
            let alertText = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Please select the stage that applies to you." : "Por favor, seleccione la etapa que le corresponde"
            
            showGeneralAlert(
                image: UIImage(named: "InfoIcon"),
                imageSize: CGSize(width: 60, height: 60),
                title: alertText,
                okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
                okAction: {
                    print("Retry action triggered")
                },
                dismissAction: {
                    print("Dismiss action triggered")
                }
            )
            return
        }

        
        showGeneralAlert(
            title: UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "We will guide you to create a strategic plan in Taking control full version." : "Le guiaremos para crear un plan estratégico en la versión completa de Taking Control.",
            okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
            okAction: {
                self.completeButtonAPICall()
            },
            showDismissButton: false
        )

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

    //MARK: - Complete Button API Call
    
    func completeButtonAPICall() {
        self.view.showToastActivity()
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        
        let params: [String: Any] = [
            "isCompleted":1,
            "patientId": userInfo.patientID,
            "sectionId":sectionID6 ?? 0
        ]

        APIService.SUpdateBasicKAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") { response in
            self.getresponseforBasicKnowAPI(response: response)
        }
    }
    
    //MARK: - Complete Button API Response
    
    func getresponseforBasicKnowAPI(response: Any) {
        self.view.hideToastActivity()
        
        if let responseDict = response as? [String: Any] {
            
            print("Response from Basic standard complete button:", responseDict)
            self.navigationController?.popViewController(animated: true)
            
        } else {
            print("Unsupported response type:", type(of: response))
        }
    }
    


}
