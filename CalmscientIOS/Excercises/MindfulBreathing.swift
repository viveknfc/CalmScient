//
//  MindfulBreathing.swift
//  sample
//
//  Created by Krishna on 8/6/24.
//

import Foundation
import UIKit
import AVFoundation
import AVKit


class MindfulBreathing: ViewController {
    
    @IBOutlet weak var preparationView: UIView!
    @IBOutlet weak var step1View: UIView!
    @IBOutlet weak var step2View: UIView!
    @IBOutlet weak var step3View: UIView!
    @IBOutlet weak var step4View: UIView!
    
    @IBOutlet weak var step6View: UIView!
    
    @IBOutlet weak var step5: UIView!
    
    @IBOutlet weak var verticalBarView: UIView!
    @IBOutlet weak var dot1View: UIView!
    @IBOutlet weak var dot2View: UIView!
    @IBOutlet weak var dot3View: UIView!
    @IBOutlet weak var dot4View: UIView!
    
    @IBOutlet weak var dot6View: UIView!
    
    @IBOutlet weak var dot5: UIView!
    
    
    @IBOutlet weak var favImg: UIImageView!
    
    @IBOutlet weak var playPauseImage: UIImageView!
    
    @IBOutlet weak var maximiseImg: UIImageView!
    
    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var progressBar: UISlider!
    
    @IBOutlet weak var preparationTitle: UILabel!
    
    @IBOutlet weak var preparationDesLabel: UILabel!
    
    @IBOutlet weak var subTitleLabel: UILabel!
    
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
    
    @IBOutlet weak var step6Label: UILabel!
    
    @IBOutlet weak var step6DescLabel: UILabel!
    
    @IBOutlet weak var videoLabel: UILabel!
    
    @IBOutlet weak var bottomDescLabel: UILabel!
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

    var languageId : Int = 1
    
    
    @IBOutlet weak var completeButton: UIButton!
    
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    
    override func viewDidLoad() {

        setupPlayer()
        setupProgressBar()
        progressBar.setThumbImage(UIImage(), for: .normal)
        progressBar.tintColor = UIColor.white
        designWidgetsSetup()
        bringControlsToFront()
        
        let playPauseRecognizer = UITapGestureRecognizer(target: self, action: #selector(playPauseTapped(tapGestureRecognizer:)))
            playPauseImage.isUserInteractionEnabled = true
            playPauseImage.addGestureRecognizer(playPauseRecognizer)
        
        let maximiseRecognizer = UITapGestureRecognizer(target: self, action: #selector(maximiseTapped(tapGestureRecognizer:)))
            maximiseImg.isUserInteractionEnabled = true
            maximiseImg.addGestureRecognizer(maximiseRecognizer)
        
        self.preparationTitle.font = UIFont(name: Fonts().lexendRegular, size: 15)
        
        self.preparationDesLabel.font = UIFont(name: Fonts().lexendLight, size: 15)
        
        self.subTitleLabel.font = UIFont(name: Fonts().lexendMedium, size: 15)
        self.subTitleLabel.textColor = UIColor(named: "lineChartLabelColor")
        self.step1Label.font = UIFont(name: Fonts().lexendRegular, size: 15)
        self.step1DescLabel.font = UIFont(name: Fonts().lexendLight, size: 15)
        self.step2Label.font = UIFont(name: Fonts().lexendRegular, size: 15)
        self.step2DescLabel.font = UIFont(name: Fonts().lexendLight, size: 15)
        self.step3Label.font = UIFont(name: Fonts().lexendRegular, size: 15)
        self.step3DescLabel.font = UIFont(name: Fonts().lexendLight, size: 15)
        self.step4Label.font = UIFont(name: Fonts().lexendRegular, size: 15)
        self.step4DescLabel.font = UIFont(name: Fonts().lexendLight, size: 15)
        self.step5Label.font = UIFont(name: Fonts().lexendRegular, size: 15)
        self.step5DescLabel.font = UIFont(name: Fonts().lexendLight, size: 15)
        
        self.step6Label.font = UIFont(name: Fonts().lexendRegular, size: 15)
        self.step6DescLabel.font = UIFont(name: Fonts().lexendLight, size: 15)
        self.videoLabel.font = UIFont(name: Fonts().lexendRegular, size: 15)
        self.bottomDescLabel.font = UIFont(name: Fonts().lexendLight, size: 15)
        if let data = UserDefaults.standard.value(forKey: "favoriteExcersises") as? Data {
            favExcercises = try! PropertyListDecoder().decode([ExcercisesModel].self, from: data)
            if let abc  = favExcercises.filter({$0.screenCode == ExcercisesTypeEnum.breathingTechnique2.rawValue}).first {
                isFav = abc.isFav
            }
        }
        setFavImage()
        let favImgTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(favImgTapped(sender:)))
        favImg.addGestureRecognizer(favImgTapGestureRecognizer)
        
        completeButton.titleLabel?.font = UIFont(name: Fonts().lexendLight, size: 14)
        
        //nav bar back button start
        let backButtonImage = UIImage(named: "NavigationBack")?.withRenderingMode(.alwaysOriginal)

        // Create a UIButton
        let backButton = UIButton(type: .custom)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonOverrideAction), for: .touchUpInside)

        // Set constraints to adjust the size
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.widthAnchor.constraint(equalToConstant: 32).isActive = true // Set desired width
        backButton.heightAnchor.constraint(equalToConstant: 32).isActive = true // Set desired height

        // Create a UIBarButtonItem using the UIButton
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarButtonItem
        
        //end

        let selectedLanguageID = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
        let title = selectedLanguageID == 1 ? "Complete" : "Finalizar"
        completeButton.setTitle(title, for: .normal)
    }
    
    @objc func backButtonOverrideAction() {
            self.navigationController?.popViewController(animated: true)
    
        }
    
    func setFavImage() {
        self.favImg.image = UIImage(named: self.isFav == 1 ? "redFav" : "fav")
    }

    func setupLanguage() {
        
             languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            
            if languageId == 1 {
                UserDefaults.standard.set("en", forKey: "Language")
            } else if languageId == 2 {
                UserDefaults.standard.set("es", forKey: "Language")
            }
        
        preparationTitle.text = AppHelper.getLocalizeString(str: "Preparation")
        preparationDesLabel.text = AppHelper.getLocalizeString(str: "First find a comfortable to either sit down or lay down. You can close your eyes if you want to.")
        
        
        subTitleLabel.text = AppHelper.getLocalizeString(str: "Let’s learn how to do the mindful breathing exercise.")
        
        step1Label.text =  AppHelper.getLocalizeString(str: "Step 1: Inhale")
        step1DescLabel.text = AppHelper.getLocalizeString(str: "Inhale through your nose until the tummy expands.")
        
        step2Label.text =  AppHelper.getLocalizeString(str: "Step 2: Exhale slowly and repeat it")
        step2DescLabel.text = AppHelper.getLocalizeString(str: "Exhale slowly through your mouse. And repeat the process.")
        
        step3Label.text =  AppHelper.getLocalizeString(str: "Step 3: Focus on the breath")
        step3DescLabel.text = AppHelper.getLocalizeString(str: "Once settled into the pattern, focus on the breath coming in through the nose and out through the mouth")
        
        step4Label.text =  AppHelper.getLocalizeString(str: "Step 4: Focus on the tummy")
        step4DescLabel.text = AppHelper.getLocalizeString(str: "Notice the rise and fall of the tummy as the breath come in and out")
        
        step5Label.text =  AppHelper.getLocalizeString(str: "Step 5: Focus on the mind")
        step5DescLabel.text = AppHelper.getLocalizeString(str: "As thoughts come into the head, notice that they are there without judgment, then let them go and bring the attention back to the breathing.")
        
        step6Label.text =  AppHelper.getLocalizeString(str: "Step 6: Focus on the connection between mind and body.")
        step6DescLabel.text = AppHelper.getLocalizeString(str: "Carry on until feeling calm, then start to be aware of how the body and mind feel.")
        
        videoLabel.text = AppHelper.getLocalizeString(str: "Now, let’s dive into it.\nPay careful attention to the following video.")
        
        bottomDescLabel.text = AppHelper.getLocalizeString(str:"Engage in this practice regularly, allowing the diaphragmatic breathing technique to guide you towards a state of tranquility and mindful breathing.")
        
        }
    
    override func viewWillAppear(_ animated: Bool) {
        title = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Mindful breathing exercise" : "Ejercicio de respiración consciente"
        setupLanguage()
        bringControlsToFront()
    }
    
    
    @objc func playPauseTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        
        if let thumbnail = videoView.viewWithTag(999) {
            thumbnail.removeFromSuperview()
        }

            if isPlaying {
                
                player.pause()
                bringControlsToFront()
                playPauseImage.image = UIImage(named: "play")
            } else {
                playPauseImage.image = UIImage(named: "pause")
                
                guard let player = player else { return }
                avController.modalPresentationStyle = .fullScreen
                avController.player = player
                player.play()
                bringControlsToFront()

            }
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
        }
    
    func designWidgetsSetup(){
       
        preparationView.applyShadow()
        step1View.applyShadow()
        step2View.applyShadow()
        step3View.applyShadow()
        step4View.applyShadow()
        step5.applyShadow()
        step6View.applyShadow()
        
        
        dot1View.layer.cornerRadius = dot1View.frame.size.width / 2
        dot1View.backgroundColor = UIColor(hex: "#6E6BB3")
        dot1View.layer.masksToBounds = true
        
        dot2View.layer.cornerRadius = dot2View.frame.size.width / 2
        dot2View.backgroundColor = UIColor(hex: "#6E6BB3")
        dot2View.layer.masksToBounds = true
        
        
        dot3View.layer.cornerRadius = dot3View.frame.size.width / 2
        dot3View.backgroundColor = UIColor(hex: "#6E6BB3")
        dot3View.layer.masksToBounds = true
        
        
        dot4View.layer.cornerRadius = dot4View.frame.size.width / 2
        dot4View.backgroundColor = UIColor(hex: "#6E6BB3")
        dot4View.layer.masksToBounds = true
        
        dot5.layer.cornerRadius = dot5.frame.size.width / 2
        dot5.backgroundColor = UIColor(hex: "#6E6BB3")
        dot5.layer.masksToBounds = true
        
        
        dot6View.layer.cornerRadius = dot6View.frame.size.width / 2
        dot6View.backgroundColor = UIColor(hex: "#6E6BB3")
        dot6View.layer.masksToBounds = true
        
        
        verticalBarView.backgroundColor = UIColor(hex: "#6E6BB3")
    }
    
    
    func bringControlsToFront() {
        
        self.view.bringSubviewToFront(maximiseImg)
            self.view.bringSubviewToFront(progressBar)
        self.view.bringSubviewToFront(playPauseImage)
        self.view.bringSubviewToFront(videoView)
        }
    
    override func viewDidAppear(_ animated: Bool) {
        bringControlsToFront()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = videoView.bounds
        if let thumbnail = videoView.viewWithTag(999) {
            thumbnail.frame = videoView.bounds
        }
        bringControlsToFront()
    }
    
    func setupPlayer() {
        
        guard let url = URL(string: UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "https://media.calmscient.in/uploads/exercises-videos/Mindfulbreathing.mp4" : "https://media.calmscient.in/uploads/exercises-spanish-videos-audios/SpanishMindfulbreathing.mp4") else { return }
        player = AVPlayer(url: url)
               playerLayer = AVPlayerLayer(player: player)
               playerLayer.frame = videoView.bounds
               playerLayer.videoGravity = .resizeAspect
               videoView.layer.addSublayer(playerLayer)
        
        // Add thumbnail image aligned with playerLayer (video area)
        if let thumbnail = UIImage(named: "thumbnail") {
            let imageView = UIImageView(image: thumbnail)
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            imageView.tag = 999
            imageView.isUserInteractionEnabled = false

            // Match playerLayer's visible bounds
            imageView.frame = playerLayer.bounds
            imageView.center = playerLayer.position  // Align in case layer is centered inside videoView

            videoView.addSubview(imageView)
        }
        
        videoView.bringSubviewToFront(playPauseImage)
        videoView.bringSubviewToFront(favImg)
        videoView.bringSubviewToFront(maximiseImg)
        videoView.bringSubviewToFront(progressBar)
        videoView.bringSubviewToFront(forwardButton)
        videoView.bringSubviewToFront(backwardButton)
        
               player.pause()
               addPeriodicTimeObserver()
        bringControlsToFront()
    }

    @IBAction func forwardButtonPressed(_ sender: Any) {
        guard let player = player, let duration = player.currentItem?.duration else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(duration)
        let newTime = min(currentTime + 10, durationSeconds)
        player.seek(to: CMTime(seconds: newTime, preferredTimescale: 600))
    }
    
    
    @IBAction func backwardButtonPressed(_ sender: Any) {
        guard let player = player else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = max(currentTime - 10, 0)
        player.seek(to: CMTime(seconds: newTime, preferredTimescale: 600))
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
    
    
    
    
    
    @IBAction func maximiseButtonAction(_ sender: Any) {

        guard let player = player else { return }
        avController.modalPresentationStyle = .fullScreen
        avController.player = player
        present(avController, animated: true) {
            player.play()
        }
    }
    
    @objc func favImgTapped(sender: UITapGestureRecognizer) {
        isFav = (isFav == 0) ? 1 : 0
        self.view.showToastActivity()
        ExcercisesRepository.shared.addFavAPICall(isFav: isFav, pageId: 1, title: ExcercisesTypeEnum.breathingTechnique2.addFavCode) { [self] result in
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

