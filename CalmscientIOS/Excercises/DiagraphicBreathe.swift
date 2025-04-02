//
//  DiagraphicBreathe.swift
//  sample
//
//  Created by Krishna on 8/6/24.
//


import Foundation
import UIKit
import AVFoundation
import AVKit


class DiagraphicBreathe: ViewController {

    @IBOutlet weak var preparationView: UIView!
    @IBOutlet weak var step1View: UIView!
    @IBOutlet weak var step2View: UIView!
    @IBOutlet weak var step3View: UIView!
    @IBOutlet weak var step4View: UIView!
    @IBOutlet weak var step5View: UIView!
    @IBOutlet weak var dot1View: UIView!
    @IBOutlet weak var dot2View: UIView!
    @IBOutlet weak var dot3View: UIView!
    @IBOutlet weak var dot4View: UIView!
    @IBOutlet weak var dot5View: UIView!
    @IBOutlet weak var verticalBar: UIView!
    @IBOutlet weak var topDescriptionLabel: UILabel!
    @IBOutlet weak var preparationLabel: UILabel!
    @IBOutlet weak var preparationDescLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var step1Label: UILabel!
    @IBOutlet weak var step1DescLabel: UILabel!
    @IBOutlet weak var step2Label: UILabel!
    @IBOutlet weak var step2DescLabel: UILabel!
    @IBOutlet weak var step3Label: UILabel!
    @IBOutlet weak var step3DescLabel: UILabel!
    @IBOutlet weak var step4Label: UILabel!
    @IBOutlet weak var step4DescLabel: UILabel!
    @IBOutlet weak var step5Label: UILabel!
    @IBOutlet weak var step5DescLabel: UILabel!
    @IBOutlet weak var videoDesc: UILabel!
    @IBOutlet weak var bottomDescLabel: UILabel!
    @IBOutlet weak var playPauseImg: UIImageView!
    @IBOutlet weak var maximiseImg: UIImageView!
    @IBOutlet weak var progressBar: UISlider!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var favImg: UIImageView!
    var isFav: Int = 0
    var favExcercises:[ExcercisesModel] = []
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var isMaximized: Bool = false
    var isPlaying = false
    var isFavorite = false
    var isFullScreen = false
    let avController = AVPlayerViewController()
    var autoHideTimer: Timer?
    var languageId :Int = 1
    
    @IBOutlet weak var completeButton: UIButton!
    
    override func viewDidLoad() {
        
        self.view.backgroundColor = .white
        super.viewDidLoad()
        setupPlayer()
        setupProgressBar()
        bringControlsToFront()
        progressBar.setThumbImage(UIImage(), for: .normal)
        progressBar.tintColor = UIColor.white
        preparationView.applyShadow()
        step1View.applyShadow()
        step2View.applyShadow()
        step3View.applyShadow()
        step4View.applyShadow()
        step5View.applyShadow()
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        dot2View.layer.cornerRadius = dot2View.frame.size.width / 2
        dot2View.backgroundColor = UIColor(hex: "#6E6BB3")
        dot2View.layer.masksToBounds = true
        
        
        dot3View.layer.cornerRadius = dot3View.frame.size.width / 2
        dot3View.backgroundColor = UIColor(hex: "#6E6BB3")
        dot3View.layer.masksToBounds = true
        
        
        dot4View.layer.cornerRadius = dot4View.frame.size.width / 2
        dot4View.backgroundColor = UIColor(hex: "#6E6BB3")
        dot4View.layer.masksToBounds = true
        
        
        dot5View.layer.cornerRadius = dot5View.frame.size.width / 2
        dot5View.backgroundColor = UIColor(hex: "#6E6BB3")
        dot5View.layer.masksToBounds = true
        
        
        dot1View.layer.cornerRadius = dot1View.frame.size.width / 2
        dot1View.backgroundColor = UIColor(hex: "#6E6BB3")
        dot1View.layer.masksToBounds = true
        
        
        verticalBar.backgroundColor = UIColor(hex: "#6E6BB3")
        
        let playPauseRecognizer = UITapGestureRecognizer(target: self, action: #selector(playPauseTapped(tapGestureRecognizer:)))
        playPauseImg.isUserInteractionEnabled = true
        playPauseImg.addGestureRecognizer(playPauseRecognizer)
        
        
            let maximiseGesture = UITapGestureRecognizer(target: self, action: #selector(maximiseTapped(tapGestureRecognizer:)))
            maximiseImg.isUserInteractionEnabled = true
            maximiseImg.addGestureRecognizer(maximiseGesture)
        if let data = UserDefaults.standard.value(forKey: "favoriteExcersises") as? Data {
            favExcercises = try! PropertyListDecoder().decode([ExcercisesModel].self, from: data)
            if let abc  = favExcercises.filter({$0.screenCode == ExcercisesTypeEnum.breathingTechnique3.rawValue}).first {
                isFav = abc.isFav
            }
        }
        setFavImage()
        let favImgTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(favImgTapped(sender:)))
        favImg.addGestureRecognizer(favImgTapGestureRecognizer)
        
        setFonts()
    }
    
    
    func setupLanguage() {
        
             languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            
            if languageId == 1 {
                UserDefaults.standard.set("en", forKey: "Language")
            } else if languageId == 2 {
                UserDefaults.standard.set("es", forKey: "Language")
            }
        
        topDescriptionLabel.text = AppHelper.getLocalizeString(str: "Doctors usually recommend diaphragmatic breathing to people with a lung condition called chronic obstructive pulmonary disease. A 2017 study found that it could also help reduce anxiety.")
        preparationLabel.text = AppHelper.getLocalizeString(str:"Preparation")
        preparationDescLabel.text = AppHelper.getLocalizeString(str: "First find a comfortable to either sit down or lay down.")
        
        subtitleLabel.text = AppHelper.getLocalizeString(str: "Let’s learn how to do the diaphragmatic breathing exercise.")
        
        step1Label.text =  AppHelper.getLocalizeString(str: "Step 1: Place your hands")
        step1DescLabel.text = AppHelper.getLocalizeString(str: "Place your hand on the tummy and other on the upper chest.")
        
        step2Label.text =  AppHelper.getLocalizeString(str: "Step 2: Inhale")
        step2DescLabel.text = AppHelper.getLocalizeString(str: "Inhale through your nose about 4 seconds,\nFocusing on the tummy rising.")
        
        step3Label.text =  AppHelper.getLocalizeString(str: "Step 3: Hold")
        step3DescLabel.text = AppHelper.getLocalizeString(str: "Hold your breath for 2 seconds.")
        
        step4Label.text =  AppHelper.getLocalizeString(str: "Step 4: Exhale")
        step4DescLabel.text = AppHelper.getLocalizeString(str: "Exhale slowly and steadily through you mouth for about 6 seconds.")
        
        step5Label.text =  AppHelper.getLocalizeString(str: "Step 5: Repeat the process")
        step5DescLabel.text = AppHelper.getLocalizeString(str: "Repeat the cycle for 5 to 10 minutes about 3 to 5 times a day")
        
        videoDesc.text = AppHelper.getLocalizeString(str: "Now, let’s dive into it.\nPay careful attention to the following video.")
        
        bottomDescLabel.text = AppHelper.getLocalizeString(str:"Engage in this practice regularly, allowing the diaphragmatic breathing technique to guide you towards a state of tranquility and mindful breathing.")
        
        }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Customize the navigation bar title font size
        title = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Diaphragmatic breathing exercise" : "Ejercicio de respiración diafragmática"
        setupLanguage()
        bringControlsToFront()
    }
    
    
    @objc func playPauseTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {

            if isPlaying {
                player.pause()
                playPauseImg.image = UIImage(named: "pause")
                
            } else {
                player.play()
                playPauseImg.image = UIImage(named: "Play")
                

            }
        bringControlsToFront()
            isPlaying.toggle()
    }
    
    
    @objc func maximiseTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        
        guard let player = player else { return }
        avController.modalPresentationStyle = .overFullScreen
        avController.player = player
        present(avController, animated: true) {
            player.play()
            
        }
        bringControlsToFront()
    }
    
    
    func bringControlsToFront() {
        self.view.bringSubviewToFront(playPauseImg)
            self.view.bringSubviewToFront(maximiseImg)
            self.view.bringSubviewToFront(progressBar)
        }
    
    override func viewDidAppear(_ animated: Bool) {
        bringControlsToFront()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = videoView.bounds
        bringControlsToFront()
    }
    
    func setupPlayer() {
        guard let url = URL(string: UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "https://calmscient.blob.core.windows.net/exercises-videos/Diaphragmaticbreathing.mp4" : "https://calmscient.blob.core.windows.net/exercises-spanish-videos-audios/SpanishDiaphragmaticbreathing.mp4") else { return }
        player = AVPlayer(url: url)
               playerLayer = AVPlayerLayer(player: player)
               playerLayer.frame = videoView.bounds
               playerLayer.videoGravity = .resizeAspect
               videoView.layer.addSublayer(playerLayer)
               videoView.bringSubviewToFront(playPauseImg)
        videoView.bringSubviewToFront(favImg)
        videoView.bringSubviewToFront(maximiseImg)
        videoView.bringSubviewToFront(progressBar)
               player.pause()
               addPeriodicTimeObserver()
        bringControlsToFront()
    }

    func setupProgressBar() {
        progressBar.value = 0
        progressBar.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }
    
    
        @objc func sliderValueChanged(_ sender: UISlider) {
            let seconds = Double(progressBar.value) * player.currentItem!.duration.seconds
            let targetTime = CMTime(seconds: seconds, preferredTimescale: 600)
            player.seek(to: targetTime)
        }
    
    
    func addPeriodicTimeObserver() {
        let interval = CMTime(seconds: 1, preferredTimescale: 600)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.updateProgressBar()
        }
    }

    func updateProgressBar() {
        guard let currentItem = player.currentItem else { return }
        let currentTime = player.currentTime().seconds
        let duration = currentItem.duration.seconds
        progressBar.value = Float(currentTime / duration)

    }
    
    
    func setFonts(){
        self.topDescriptionLabel.font = UIFont(name: Fonts().lexendLight, size: 15)
        self.preparationLabel.font = UIFont(name: Fonts().lexendRegular, size: 15)
        self.preparationDescLabel.font = UIFont(name: Fonts().lexendLight, size: 15)
        self.subtitleLabel.font = UIFont(name: Fonts().lexendMedium, size: 15)
        self.subtitleLabel.textColor = UIColor(named: "lineChartLabelColor")
        self.preparationLabel.font = UIFont(name: Fonts().lexendRegular, size: 15)
        self.preparationDescLabel.font = UIFont(name: Fonts().lexendLight, size: 15)
        self.step1Label.font = UIFont(name: Fonts().lexendMedium, size: 15)
        self.step1DescLabel.font = UIFont(name: Fonts().lexendLight, size: 15)
        
        self.step2Label.font = UIFont(name: Fonts().lexendMedium, size: 15)
        self.step2DescLabel.font = UIFont(name: Fonts().lexendLight, size: 15)
        
        self.step3Label.font = UIFont(name: Fonts().lexendMedium, size: 15)
        self.step3DescLabel.font = UIFont(name: Fonts().lexendLight, size: 15)
        
        self.step4Label.font = UIFont(name: Fonts().lexendMedium, size: 15)
        self.step4DescLabel.font = UIFont(name: Fonts().lexendLight, size: 15)
        
        self.step5Label.font = UIFont(name: Fonts().lexendMedium, size: 15)
        self.step5DescLabel.font = UIFont(name: Fonts().lexendLight, size: 15)
        
        self.videoDesc.font = UIFont(name: Fonts().lexendLight, size: 15)
        self.bottomDescLabel.font = UIFont(name: Fonts().lexendLight, size: 15)
        
        completeButton.titleLabel?.font = UIFont(name: Fonts().lexendLight, size: 14)
   
    }
    
    func setFavImage() {
        self.favImg.image = UIImage(named: self.isFav == 1 ? "redFav" : "fav")
    }

    @objc func favImgTapped(sender: UITapGestureRecognizer) {
        isFav = (isFav == 0) ? 1 : 0
        self.view.showToastActivity()
        ExcercisesRepository.shared.addFavAPICall(isFav: isFav, pageId: 1, title: ExcercisesTypeEnum.breathingTechnique3.addFavCode) { [self] result in
            switch result {
            case .success(let data):
                // Convert data to JSON object and print it
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async {
                            self.setFavImage()
                            self.view.hideToastActivity()
                            if let msg = json["responseMessage"] {
                                self.view.showToast(message: msg as! String)
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.view.hideToastActivity()
                        }
                    }
                } catch {
                    print("Error converting data to JSON: \(error)")
                    DispatchQueue.main.async {
                        self.view.hideToastActivity()
                    }
                }
            case .failure(let error):
                print("Error: \(error)")
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                }
            }
        }

    }
    
    @IBAction func completeButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
//        let destinationVC = UIStoryboard(name: "Excercises", bundle: nil).instantiateViewController(withIdentifier: "Excercises") as! Excercises
//                
//                // Push to the destination view controller
//                self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    
}
