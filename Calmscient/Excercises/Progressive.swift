//
//  Progressive.swift
//  sample
//
//  Created by Krishna on 8/6/24.
//
import UIKit
import AVFAudio
import AVFoundation

class Progressive: ViewController {
    
    @IBOutlet weak var equalizerImg: UIImageView!
    var player: AVPlayer?
    
    @IBOutlet weak var favImg: UIImageView!
    @IBOutlet weak var playAudioImg: UIImageView!
    @IBOutlet weak var rewindImg: UIImageView!
    @IBOutlet weak var forwardImg: UIImageView!
    
    @IBOutlet weak var completeButton: CapsuleButton1!
    
    var isObservingStatus = false
    var redOverlayView: UIView!
    var languageId : Int = 1
    var isPlayerReady = false
    var isFav: Int = 0
    var favExcercises:[ExcercisesModel] = []
    var audioURL: String {
        return UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "https://media.calmscient.in/uploads/exercises-audios/ProgressiveMuscleRelaxationEnglishWithMusic.wav" : "https://media.calmscient.in/uploads/exercises-audios/ProgressiveMuscleRelaxationWithMusicSpanish.wav"
    }
    
    override func viewDidLoad() {

        self.title = AppHelper.getLocalizeString(str:"Progressive muscle relaxation")
        guard let url = URL(string: audioURL) else {
            print("Invalid URL")
            return
        }
        
        let playerItem = AVPlayerItem(url: url)
        playerItem.preferredPeakBitRate = 1000000 // Set preferred peak bit rate (in bits per second)

        player = AVPlayer(playerItem: playerItem)
        
        player?.automaticallyWaitsToMinimizeStalling = true // AVPlayer will automatically wait to minimize stalling

        // Observe the player's playback status
        player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)

        // Start the activity indicator
//        self.view.showToastActivity()
        if let data = UserDefaults.standard.value(forKey: "favoriteExcersises") as? Data {
            favExcercises = try! PropertyListDecoder().decode([ExcercisesModel].self, from: data)
            if let abc  = favExcercises.filter({$0.screenCode == ExcercisesTypeEnum.progressive.rawValue}).first {
                isFav = abc.isFav
            }
        }
        setFavImage()
        // Adding gesture recognizers
        addGestureRecognizers()
        setupPlayerObserver()
        
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
    }
    
    @objc func backButtonOverrideAction() {
            self.navigationController?.popViewController(animated: true)
    
        }
    
    override func viewWillAppear(_ animated: Bool) {
        setupLanguage()
    }
    
    
    func setupPlayerObserver() {
        // Observe the status of the player to check if it's ready to play
        player?.currentItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        isObservingStatus = true
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print(keyPath)
        if keyPath == "timeControlStatus" {
            if player?.timeControlStatus == .waitingToPlayAtSpecifiedRate {
                self.view.showToastActivity()
                // Show buffering indicator
            } else if player?.timeControlStatus == .playing {
                // Hide buffering indicator
                self.view.hideToastActivity()
            }
        }
        if keyPath == "status" {
            if player?.status == .readyToPlay {
                isPlayerReady = true
                // Stop the activity indicator and show the play button
                self.view.hideToastActivity()
                playAudioImg.isHidden = false
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Stop the audio when the view is about to disappear
        if self.isMovingFromParent {
            player?.pause()
        }
//      removeStatusObserver()
    }
    
    deinit {
        removeStatusObserver()
    }
    
    func removeStatusObserver() {
        guard isObservingStatus else { return }
        player?.currentItem?.removeObserver(self, forKeyPath: "status")
        isObservingStatus = false
    }
    
    func setupLanguage() {
        
             languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
        
        
            if languageId == 1 {
                UserDefaults.standard.set("en", forKey: "Language")
            } else if languageId == 2 {
                UserDefaults.standard.set("es", forKey: "Language")
            }
        }
    
    func addGestureRecognizers() {        
        let rewindGesture = UITapGestureRecognizer(target: self, action: #selector(rewindTapped(tapGestureRecognizer:)))
        rewindImg.isUserInteractionEnabled = true
        rewindImg.addGestureRecognizer(rewindGesture)
        
        let forwardGesture = UITapGestureRecognizer(target: self, action: #selector(forwardTapped(tapGestureRecognizer:)))
        forwardImg.isUserInteractionEnabled = true
        forwardImg.addGestureRecognizer(forwardGesture)
        
        let playPauseGesture = UITapGestureRecognizer(target: self, action: #selector(playPauseTapped(tapGestureRecognizer:)))
        playAudioImg.isUserInteractionEnabled = true
        playAudioImg.addGestureRecognizer(playPauseGesture)
        
        let favImgTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(favImgTapped(sender:)))
        favImg.addGestureRecognizer(favImgTapGestureRecognizer)
    }
    
    func setFavImage() {
        self.favImg.image = UIImage(named: self.isFav == 1 ? "redFav" : "fav")
    }

    @objc func rewindTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        guard let player = player else { return }
        let currentTime = player.currentTime()
        let newTime = CMTimeSubtract(currentTime, CMTimeMakeWithSeconds(10, preferredTimescale: currentTime.timescale))
        player.seek(to: newTime)
    }
    
    @objc func forwardTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        guard let player = player else { return }
        let currentTime = player.currentTime()
        let newTime = CMTimeAdd(currentTime, CMTimeMakeWithSeconds(10, preferredTimescale: currentTime.timescale))
        player.seek(to: newTime)
    }
    
    @objc func updateOverlayView() {
        guard let player = player else { return }
        let totalDuration = player.currentItem?.duration.seconds ?? 1.0
        let currentTime = player.currentTime().seconds
        let progress = CGFloat(currentTime / totalDuration)
        
        let newWidth = equalizerImg.frame.width * progress
        redOverlayView.frame = CGRect(x: 0, y: 0, width: newWidth, height: equalizerImg.frame.height)
        
        // Stop the timer if the audio has finished playing
        if progress >= 1.0 {
            redOverlayView.frame = CGRect(x: 0, y: 0, width: equalizerImg.frame.width, height: equalizerImg.frame.height)
        }
    }
    
    @objc func playPauseTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        guard isPlayerReady else { return } // Ensure the player is ready
        
        if redOverlayView == nil {
            equalizerImg.contentMode = .scaleToFill
            
            // Create the red overlay view
            redOverlayView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: equalizerImg.frame.height))
            redOverlayView.backgroundColor = UIColor(hex: "#F48383")
            equalizerImg.addSubview(redOverlayView)
            
            // Create the mask layer
            let maskLayer = CAShapeLayer()
            maskLayer.frame = equalizerImg.bounds
            
            // Use the image as the mask
            maskLayer.contents = equalizerImg.image?.cgImage
            redOverlayView.layer.mask = maskLayer
        }
        
        // Play or pause audio
        if player?.timeControlStatus == .playing {
            playAudioImg.image = UIImage(named: "playAudio")
            player?.pause()
        } else {
            playAudioImg.image = UIImage(named: "pause")
            player?.play()
        }
        
        // Start a timer to update the red overlay view based on the audio progress
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateOverlayView), userInfo: nil, repeats: true)
    }
    
    @objc func favImgTapped(sender: UITapGestureRecognizer) {
        isFav = (isFav == 0) ? 1 : 0
        self.view.showToastActivity()
        ExcercisesRepository.shared.addFavAPICall(isFav: isFav, pageId: 1, title: ExcercisesTypeEnum.progressive.addFavCode) { [self] result in
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
    }
    
}

