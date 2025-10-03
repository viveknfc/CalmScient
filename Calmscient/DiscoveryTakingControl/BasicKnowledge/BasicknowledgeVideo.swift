//
//  VideoController.swift
//  CalmscientIOS
//
//  Created by mac on 27/05/24.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

class BasicknowledgeVideo: ViewController {
    @IBOutlet weak var main_View: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var normal_text: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var maximizeButton: UIButton!
    @IBOutlet weak var progressBar: UISlider!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var questionLbl: UILabel!
    @IBOutlet weak var subtitleLbl: UILabel!
    @IBOutlet weak var completeButton: CapsuleButton1!
    
    var timeObserverToken: Any?
    
    var isFav: Int = 0
    let homeVC = HomeTabDashboardViewController()
    
    var sectionID4: Int?
    //        @IBOutlet weak var timeLabel: UILabel!
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var isMaximized: Bool = false
    var isPlaying = false
    var isFavorite = false
    var isFullScreen = false
    var autoHideTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
        setupProgressBar()
        bringControlsToFront()
        progressBar.setThumbImage(UIImage(), for: .normal)
        progressBar.tintColor = UIColor.white
        title =  AppHelper.getLocalizeString(str: "Basic Knowledge")
        
        // Initially disabled
        completeButton.isEnabled = false
        completeButton.alpha = 0.5

        // Attach generic observer
        timeObserverToken = player?.observeRemainingTime(threshold: 10) { [weak self] canEnable in
            guard let self = self else { return }
            self.completeButton.isEnabled = canEnable
            self.completeButton.alpha = canEnable ? 1.0 : 0.5
        }
        
    }
    
    deinit {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        normal_text.textColor = UIColor(named: "424242Color")
        normal_text.text = AppHelper.getLocalizeString(str:"This video explains the impact of alcohol on the brain and its subsequent effects. Having this knowledge will help you consider your drinking habits." )
        
        questionLbl.text =  AppHelper.getLocalizeString(str: "DRINKING_CONTROL_Consequence_What_Happens_To_Your_Brain_When_You_Drink")
        
        subtitleLbl.text = AppHelper.getLocalizeString(str:"Let’s watch the videos ")
        completeButton.updateTitleForLanguage()
        
        fetchFavorite()
    }
    
    @IBAction func maximiseButtonAction(_ sender: Any) {
        print("max button clicked from tipsy turth")
        let videoURL = URL(string: "https://media.calmscient.in/uploads/course/Tipsy_truth_with_subtitle.mp4")!
        let avPlayer = AVPlayer(url: videoURL)
        let avController = AVPlayerViewController()
        avController.player = avPlayer
        avController.modalPresentationStyle = .overFullScreen
        present(avController, animated: true) {
            avPlayer.play()
        }
    }
    
    //MARK: - Fetch Fav
    
    func fetchFavorite() {
        
        self.view.showToastActivity()
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        
        homeVC.getPatientFavorites(plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID, parentId: 0) { result in
            switch result {
            case .success(let data):
                do {
                    let decoded = try JSONDecoder().decode(FavoritesResponse.self, from: data)
                    
                    if let match = decoded.favorites.first(where: { $0.title == "What happens to your brain when you drink?" }) {
                        print("Found → isFavorite = \(match.isFavorite)")
                        self.isFav = match.isFavorite
                        
                        DispatchQueue.main.async {
                            self.setFavImage()
                            self.view.hideToastActivity()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.view.hideToastActivity()
                        }
                        print("Title not found in favorites")
                    }
                } catch {
                    self.view.hideToastActivity()
                    print("Decoding error: \(error)")
                }
                
            case .failure(let error):
                self.view.hideToastActivity()
                print("API failed: \(error)")
            }
        }
    }
    
    func setupPlayer() {
        
        guard let url = URL(string: "https://media.calmscient.in/uploads/course/Tipsy_truth_with_subtitle.mp4") else { return }
        
        //http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4
        
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoView.bounds
        playerLayer.videoGravity = .resizeAspect
        videoView.layer.addSublayer(playerLayer)
        player.pause()
        addPeriodicTimeObserver()
        bringControlsToFront()
    }
    
    func setupProgressBar() {
        progressBar.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }

    @IBAction func playPauseTapped(_ sender: UIButton) {
        if isPlaying {
            playPauseButton.setImage(UIImage(named: "play"), for: .normal)
            playPauseButton.alpha = 1.0
            player.pause()
            playPauseButton.setTitle("Play", for: .normal)
            let videoURL = URL(string: "https://media.calmscient.in/uploads/course/Tipsy_truth_with_subtitle.mp4")!
            _ = AVPlayer(url: videoURL)
            _ = AVPlayerViewController()

        } else {
            playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
            player.play()
            playPauseButton.alpha = 0.5
            playPauseButton.setTitle("Pause", for: .normal)
            // resetAutoHideTimer()
        }
        isPlaying.toggle()
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

    func formatTime(seconds: Double) -> String {
        let mins = Int(seconds / 60)
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        
        print("fav button tapped from tipsy truth")
        isFav = (isFav == 0) ? 1 : 0
        
        self.view.showToastActivity()
        ExcercisesRepository.shared.addFavAPICall(isFav: isFav, pageId: 1, title: "What happens to your brain when you drink?") { [self] result in
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
    
    func setFavImage() {
        let imageName = isFav == 1 ? "redFav" : "fav"
        favoriteButton.setImage(UIImage(named: imageName), for: .normal)
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        // Handle adding to favorite
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    func bringControlsToFront() {
        self.view.bringSubviewToFront(favoriteButton)
        self.view.bringSubviewToFront(maximizeButton)
        self.view.bringSubviewToFront(progressBar)
        //            self.view.bringSubviewToFront(timeLabel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = videoView.bounds
        bringControlsToFront()
    }
    func setupAutoHideTimer() {
        resetAutoHideTimer()
    }
    
    func resetAutoHideTimer() {
        autoHideTimer?.invalidate()
        autoHideTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(hideControls), userInfo: nil, repeats: false)
        showControls()
    }
    
    @objc func hideControls() {
        playPauseButton.isHidden = false
        favoriteButton.isHidden = false
        maximizeButton.isHidden = false
        progressBar.isHidden = false
    }
    
    func showControls() {
        playPauseButton.isHidden = false
        favoriteButton.isHidden = false
        maximizeButton.isHidden = false
        progressBar.isHidden = false
    }
    
    //MARK: - Complete Button Pressed
    
    @IBAction func completeBUttonPressed(_ sender: Any) {
        completeButtonAPICall()
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
            "sectionId":sectionID4 ?? 0
        ]

        APIService.DUpdateBasicKAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") { response in
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
