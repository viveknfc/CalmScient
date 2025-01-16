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

@available(iOS 16.0, *)
class VideoController: ViewController {
    @IBOutlet weak var main_View: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var maximizeButton: UIButton!
    @IBOutlet weak var progressBar: UISlider!
    @IBOutlet weak var playPauseButton: UIButton!
    
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var isMaximized: Bool = false
    var isPlaying = false
    var isFavorite = false
    var isFullScreen = false
    var autoHideTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationItem.leftBarButtonItem?.isHidden = false
        self.navigationController?.isNavigationBarHidden = false
        setupPlayer()
        setupProgressBar()
        bringControlsToFront()
        progressBar.setThumbImage(UIImage(), for: .normal)
        progressBar.tintColor = UIColor.white
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationItem.leftBarButtonItem?.isHidden = false
        self.navigationController?.isNavigationBarHidden = false

    }
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationItem.leftBarButtonItem?.isHidden = false
        self.navigationController?.isNavigationBarHidden = false
    }
    @IBAction func maximiseAction(_ sender: Any) {
        let videoURL = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
        let avPlayer = AVPlayer(url: videoURL)
        let avController = AVPlayerViewController()
        avController.player = avPlayer
        present(avController, animated: true) {
            avPlayer.play()
        }
    }

    
  
    func setupPlayer() {
        guard let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4") else { return }
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
            player.pause()
            playPauseButton.setTitle("Play", for: .normal)
            let videoURL = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
            let avPlayer = AVPlayer(url: videoURL)
            let avController = AVPlayerViewController()
            avController.player = avPlayer
            present(avController, animated: true) {
                avPlayer.play()
            }
        } else {
            player.play()
            playPauseButton.setTitle("Pause", for: .normal)
            resetAutoHideTimer()
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
        //            resetAutoHideTimer()
        
        //            timeLabel.text = formatTime(seconds: currentTime) + " / " + formatTime(seconds: duration)
    }
    @IBAction func forwardButtonTapped(_ sender: UIButton) {
        let next = UIStoryboard(name: "TakingControllIntro", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "TakingControllIntro") as? TakingControllIntro
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    func formatTime(seconds: Double) -> String {
        let mins = Int(seconds / 60)
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        // Handle adding to favorite
        isFavorite.toggle()
        let favoriteTitle = isFavorite ? "Unfavorite" : "Favorite"
        favoriteButton.setTitle(favoriteTitle, for: .normal)
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
    
}
