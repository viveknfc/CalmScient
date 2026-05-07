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
    var timeObserverToken: Any?
    
    var progressTimer: Timer?
    
    var isObservingStatus = false
    var redOverlayView: UIView!
    var languageId: Int = 1
    var isPlayerReady = false
    var isFav: Int = 0
    var favExcercises: [ExcercisesModel] = []
    
    private var needsPlayerRetry = false
    
    var audioURL: String {
        return UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1
            ? "https://media.calmscient.in/uploads/exercises-audios/ProgressiveMuscleRelaxationEnglishWithMusic.wav"
            : "https://media.calmscient.in/uploads/exercises-audios/ProgressiveMuscleRelaxationWithMusicSpanish.wav"
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = AppHelper.getLocalizeString(str: "Progressive muscle relaxation")
        
        configureAudioSession()
        setupPlayer()
        setupFavourites()
        addGestureRecognizers()
        setupPlayerObserver()
        setupCompleteButton()
        setupBackButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLanguage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            player?.pause()
            invalidateProgressTimer()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .networkStatusChanged, object: nil)
        removeStatusObserver()
        removeTimeControlStatusObserver()
        invalidateProgressTimer()
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
        }
    }
    
    // MARK: - Setup
    
    private func setupPlayer() {
        guard let url = URL(string: audioURL) else {
            print("Invalid URL")
            return
        }
        
        let playerItem = AVPlayerItem(url: url)
        playerItem.preferredPeakBitRate = 1000000
        
        player = AVPlayer(playerItem: playerItem)
        player?.automaticallyWaitsToMinimizeStalling = true
        player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
    }
    
    private func setupFavourites() {
        if let data = UserDefaults.standard.value(forKey: "favoriteExcersises") as? Data {
            favExcercises = (try? PropertyListDecoder().decode([ExcercisesModel].self, from: data)) ?? []
            if let match = favExcercises.first(where: { $0.screenCode == ExcercisesTypeEnum.progressive.rawValue }) {
                isFav = match.isFav
            }
        }
        setFavImage()
    }
    
    private func setupCompleteButton() {
        completeButton.titleLabel?.font = UIFont(name: Fonts().lexendLight, size: 14)
        completeButton.isEnabled = false
        completeButton.alpha = 0.5
        
        timeObserverToken = player?.observeRemainingTime(threshold: 10) { [weak self] canEnable in
            guard let self else { return }
            self.completeButton.isEnabled = canEnable
            self.completeButton.alpha = canEnable ? 1.0 : 0.5
        }
    }
    
    private func setupBackButton() {
        let backButtonImage = UIImage(named: "NavigationBack")?.withRenderingMode(.alwaysOriginal)
        let backButton = UIButton(type: .custom)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonOverrideAction), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    func setupPlayerObserver() {
        player?.currentItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        isObservingStatus = true
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged(_:)),
            name: .networkStatusChanged,
            object: nil
        )
    }
    
    // MARK: - Network
    
    @objc private func networkStatusChanged(_ notification: Notification) {
        guard let isConnected = notification.object as? Bool,
              isConnected,
              needsPlayerRetry else { return }
        needsPlayerRetry = false
        retryPlayer()
    }
    
    private func retryPlayer() {
        removeStatusObserver()
        
        guard let url = URL(string: audioURL) else { return }
        let newItem = AVPlayerItem(url: url)
        newItem.preferredPeakBitRate = 1000000
        player?.replaceCurrentItem(with: newItem)
        
        player?.currentItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        isObservingStatus = true
        
        self.view.showToastActivity()
    }
    
    // MARK: - Audio Session
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }
    
    // MARK: - KVO
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus" {
            switch player?.timeControlStatus {
            case .waitingToPlayAtSpecifiedRate:
                self.view.showToastActivity()
            case .playing:
                self.view.hideToastActivity()
            case .paused:
                self.view.hideToastActivity()
            default:
                break
            }
            
        } else if keyPath == "status" {
            guard let item = player?.currentItem else { return }
            switch item.status {
            case .readyToPlay:
                isPlayerReady = true
                needsPlayerRetry = false
                self.view.hideToastActivity()
                playAudioImg.isHidden = false
                
            case .failed:
                isPlayerReady = false
                self.view.hideToastActivity()
                playAudioImg.isHidden = false
                invalidateProgressTimer()
                needsPlayerRetry = true
                let msg = NetworkMonitor.shared.isConnected
                    ? "Unable to play audio. Please try again."
                    : "Audio is not available offline."
                self.view.showToast(message: AppHelper.getLocalizeString(str: msg))
                
            case .unknown:
                break
            @unknown default:
                break
            }
        }
    }
    
    // MARK: - Observers cleanup
    
    func removeStatusObserver() {
        guard isObservingStatus else { return }
        player?.currentItem?.removeObserver(self, forKeyPath: "status")
        isObservingStatus = false
    }
    
    private func removeTimeControlStatusObserver() {
        player?.removeObserver(self, forKeyPath: "timeControlStatus")
    }
    
    private func invalidateProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    // MARK: - Language
    
    func setupLanguage() {
        languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
        if languageId == 1 {
            UserDefaults.standard.set("en", forKey: "Language")
        } else if languageId == 2 {
            UserDefaults.standard.set("es", forKey: "Language")
        }
    }
    
    // MARK: - Gestures
    
    func addGestureRecognizers() {
        let rewindGesture = UITapGestureRecognizer(target: self, action: #selector(rewindTapped))
        rewindImg.isUserInteractionEnabled = true
        rewindImg.addGestureRecognizer(rewindGesture)
        
        let forwardGesture = UITapGestureRecognizer(target: self, action: #selector(forwardTapped))
        forwardImg.isUserInteractionEnabled = true
        forwardImg.addGestureRecognizer(forwardGesture)
        
        let playPauseGesture = UITapGestureRecognizer(target: self, action: #selector(playPauseTapped))
        playAudioImg.isUserInteractionEnabled = true
        playAudioImg.addGestureRecognizer(playPauseGesture)
        
        let favGesture = UITapGestureRecognizer(target: self, action: #selector(favImgTapped))
        favImg.isUserInteractionEnabled = true
        favImg.addGestureRecognizer(favGesture)
    }
    
    // MARK: - Playback Actions
    
    @objc func rewindTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        guard let player else { return }
        let newTime = CMTimeSubtract(player.currentTime(), CMTimeMakeWithSeconds(10, preferredTimescale: player.currentTime().timescale))
        player.seek(to: newTime)
    }
    
    @objc func forwardTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        guard let player else { return }
        let newTime = CMTimeAdd(player.currentTime(), CMTimeMakeWithSeconds(10, preferredTimescale: player.currentTime().timescale))
        player.seek(to: newTime)
    }
    
    @objc func playPauseTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        guard let item = player?.currentItem else { return }
        
        guard item.status == .readyToPlay else {
            if needsPlayerRetry && NetworkMonitor.shared.isConnected {
                retryPlayer()
            } else {
                self.view.showToast(message: AppHelper.getLocalizeString(str: "Audio is not available offline."))
            }
            return
        }
        
        if redOverlayView == nil {
            equalizerImg.contentMode = .scaleToFill
            redOverlayView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: equalizerImg.frame.height))
            redOverlayView.backgroundColor = UIColor(hex: "#F48383")
            equalizerImg.addSubview(redOverlayView)
            let maskLayer = CAShapeLayer()
            maskLayer.frame = equalizerImg.bounds
            maskLayer.contents = equalizerImg.image?.cgImage
            redOverlayView.layer.mask = maskLayer
        }
        
        if player?.timeControlStatus == .playing {
            playAudioImg.image = UIImage(named: "playAudio")
            player?.pause()
            invalidateProgressTimer()
        } else {
            playAudioImg.image = UIImage(named: "pause")
            player?.play()
            if progressTimer == nil {
                progressTimer = Timer.scheduledTimer(
                    timeInterval: 0.1,
                    target: self,
                    selector: #selector(updateOverlayView),
                    userInfo: nil,
                    repeats: true
                )
            }
        }
    }
    
    @objc func updateOverlayView() {
        guard let player, let item = player.currentItem else { return }
        let duration = item.duration
        let total = duration.isIndefinite ? 0 : duration.seconds
        guard total.isFinite, total > 0 else { return }
        let currentTime = player.currentTime().seconds
        let progress = CGFloat(max(0, min(currentTime, total)) / total)
        redOverlayView.frame = CGRect(x: 0, y: 0, width: equalizerImg.frame.width * progress, height: equalizerImg.frame.height)
        if progress >= 1.0 {
            redOverlayView.frame = CGRect(x: 0, y: 0, width: equalizerImg.frame.width, height: equalizerImg.frame.height)
            invalidateProgressTimer()
        }
    }
    
    // MARK: - Favourite
    
    func setFavImage() {
        favImg.image = UIImage(named: isFav == 1 ? "redFav" : "fav")
    }
    
    @objc func favImgTapped(sender: UITapGestureRecognizer) {
        isFav = (isFav == 0) ? 1 : 0
        self.view.showToastActivity()
        
        ExcercisesRepository.shared.addFavAPICall(
            isFav: isFav,
            pageId: 1,
            title: ExcercisesTypeEnum.progressive.addFavCode
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async {
                            self.setFavImage()
                            self.view.hideToastActivity()
                            if let msg = json["responseMessage"] as? String {
                                self.view.showToast(message: msg)
                            }
                        }
                    } else {
                        DispatchQueue.main.async { self.view.hideToastActivity() }
                    }
                } catch {
                    print("JSON error: \(error)")
                    DispatchQueue.main.async { self.view.hideToastActivity() }
                }
            case .failure(let error):
                print("Error: \(error)")
                DispatchQueue.main.async { self.view.hideToastActivity() }
            }
        }
    }
    
    // MARK: - Actions
    
    @objc func backButtonOverrideAction() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func completeButtonPressed(_ sender: Any) {
        guard NetworkMonitor.shared.isConnected else {
            DispatchQueue.main.async {
                NoInternetBanner.shared.show()
            }
            return
        }
        navigationController?.popViewController(animated: true)
    }
}
