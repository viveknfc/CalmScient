//
//  NeedToTalkViewController.swift
//  CalmscientIOS
//
//  Created by BVK on 21/07/24.
//

import UIKit

class NeedToTalkViewController: ViewController {
    @IBOutlet weak var phoneNumber: UILabel!
    
    @IBOutlet weak var doctorSubtitle: UILabel!
    @IBOutlet weak var doctorName: UILabel!
    
    @IBOutlet weak var needToTalkTableView: UITableView!
    var needToTalkData: [[String: Any]] = []
    
    let links: [String: String] = [
              "988": "tel://988",
              "741741": "sms:741741",
              "678678": "sms:678678",
          ]

    override func viewDidLoad() {
        super.viewDidLoad()
        needToTalkTableView.register(UINib(nibName: "NeedToTalkTableViewCell", bundle: nil), forCellReuseIdentifier: "NeedToTalkTableViewCell")
        
        self.navigationController?.isNavigationBarHidden = false
        
        doctorName.font = UIFont(name: Fonts().lexendMedium, size: 20)
        doctorSubtitle.font = UIFont(name: Fonts().lexendBold, size: 12)
        phoneNumber.font = UIFont(name: Fonts().lexendMedium, size: 17)
        
        needToTalkTableView.dataSource = self
        needToTalkTableView.delegate = self
        needToTalkTableView.estimatedRowHeight = 44
        needToTalkTableView.rowHeight = UITableView.automaticDimension
        
        self.view.showToastActivity()
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        
        getNeedToTalkData(patientId: userInfo.patientID, bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
            switch result {
            case .success(let data):
                // Convert data to JSON object and print it
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async {
                            print("Need to talk data is ",json)
                            self.view.hideToastActivity()
                            if let need = json["providerDetails"] as? [String: Any] {
                                if let docName = need["providerName"] as? String {
                                    self.doctorName.text = docName
                                } else {
                                    print("providerName key is missing or not a String")
                                }
                                if let docNameSub = need["location"] as? String {
                                    self.doctorSubtitle.text = docNameSub
                                } else {
                                    print("providerName key is missing or not a String")
                                }
                                if let docNamePhone = need["phoneNumber"] as? String {
                                    self.phoneNumber.text = docNamePhone
                                } else {
                                    self.phoneNumber.text = "Not Updated"
                                }
                                
                            } else {
                                print("providerDetails key is missing or not a dictionary")
                            }
                            
                            if let needArray = json["needToTalkWithSomeOne"] as? [[String: Any]] {
                                self.needToTalkData = needArray
                                DispatchQueue.main.async {
                                    self.needToTalkTableView.reloadData()
                                }
                            } else {
                                print("Failed to cast JSON data")
                            }
                            
                            
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
        self.title = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ?  "Emergency resources" : "Recursos de emergencia."
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: Fonts().lexendMedium, size: 18)!,]
        navigationController?.navigationBar.titleTextAttributes = attributes
        needToTalkTableView.reloadData()
        // Do any additional setup after loading the view.
        
        // Enable interaction
        phoneNumber.isUserInteractionEnabled = true
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(callPhoneNumber))
        phoneNumber.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func callPhoneNumber() {
        guard let number = phoneNumber.text,
              let url = URL(string: "tel://\(number.filter { $0.isNumber })"),
              UIApplication.shared.canOpenURL(url) else {
            // Optionally handle invalid number or error
            return
        }
        UIApplication.shared.open(url)
    }
    
    func setupLanguage() {
        
            let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            
            if languageId == 1 {
                UserDefaults.standard.set("en", forKey: "Language")
            } else if languageId == 2 {
                UserDefaults.standard.set("es", forKey: "Language")
            }
        
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLanguage()
        needToTalkTableView.reloadData()
        self.navigationController?.isNavigationBarHidden = false
    }
    func getNeedToTalkData(patientId: Int,bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
        // Define the URL
        guard let url = URL(string: "\(baseURLString)identity/api/v1/settings/getNeedToTalkWithSomeoneDetails") else {
            print("Invalid URL")
            return
        }
   // https://calmscient.centralindia.cloudapp.azure.com:8090/identity/api/v1/settings/getNeedToTalkWithSomeoneDetails
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        
        
        // Define the JSON payload
        let payload: [String: Any] = [
                        "patientId": patientId,
        ]
        print("payload\(payload)")
        // Convert the payload to JSON data
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            request.httpBody = jsonData
            print(jsonData)
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
    
   
}
extension NeedToTalkViewController : UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return needToTalkData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NeedToTalkTableViewCell", for: indexPath) as! NeedToTalkTableViewCell
        
        let event = needToTalkData[indexPath.row]
                
                if let eventName = event["title"] as? String {
                    cell.titleLabel.text = eventName
                } else {
                    cell.titleLabel.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "No title available" : "Título no disponible."
                }
                
                if let eventContent = event["content"] as? String {
//                    cell.desTextView.text = eventContent
                    cell.desTextView.dataDetectorTypes = [.link, .phoneNumber]
                    cell.desTextView.isSelectable = true
                    cell.desTextView.isEditable = false
                    cell.desTextView.isScrollEnabled = false

                    let attributedString = NSMutableAttributedString(string: eventContent, attributes: [
                                .font: UIFont(name: Fonts().lexendRegular, size: 14) ?? UIFont.systemFont(ofSize: 14),
                                .foregroundColor: UIColor.black
                            ])
                    
                    for (text, link) in links {
                               let range = (eventContent as NSString).range(of: text)
                               if range.location != NSNotFound {
                                   attributedString.addAttribute(.link, value: link, range: range)
                               }
                           }
                    
                    cell.desTextView.attributedText = attributedString
                    cell.desTextView.linkTextAttributes = [
                        .foregroundColor: #colorLiteral(red: 0.431372549, green: 0.4196078431, blue: 0.7019607843, alpha: 1)
                        , .underlineStyle: NSUnderlineStyle.single.rawValue
                            ]
                    
//                    cell.descriptionLabel.text = eventContent
                    
                } else {
                    cell.descriptionLabel.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ?  "No content available" : "No hay contenido disponible."
                }
        cell.learnMoreButton.setTitle(UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Learn more" : "Aprende más.", for: .normal)  
        cell.learnMoreButton.tag = indexPath.row

        cell.learnMoreButton.addTarget(self, action: #selector(NeedToTalkViewController.learnMoreButtonClicked(_:)), for: .touchUpInside)

        return cell
    }
    
    @objc func learnMoreButtonClicked(_ sender: UIButton) {
            let index = sender.tag
            let event = needToTalkData[index]
            if let url = event["learnMore"] as? String {
                print("Learn More URL for row \(index): \(url)")
                
                let next = UIStoryboard(name: "FavoritesVideosWebViewController", bundle: nil)
                let vc = next.instantiateViewController(withIdentifier: "FavoritesVideosWebViewController") as? FavoritesVideosWebViewController
                vc?.favURL = url
                vc?.title = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ?  "Emergency resources" : "Recursos de emergencia."
                self.navigationController?.pushViewController(vc!, animated: true)
                
                
            } else {
                print("No URL available for row \(index)")
            }
        }
}

