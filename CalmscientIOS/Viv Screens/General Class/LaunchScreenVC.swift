//
//  LaunchScreenVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 25/03/25.
//

import UIKit
import SwiftyGif

@available(iOS 16.0, *)
class LaunchScreenVC: UIViewController {
    
    @IBOutlet weak var launchGif: UIImageView!
    weak var sceneDelegate: SceneDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        print("🔥 LaunchScreenVC viewDidLoad called")

        do {
            print("🎬 Loading GIF in viewDidLoad")
            let gif = try UIImage(gifName: "launchGifWhite.gif")
            launchGif.setGifImage(gif, loopCount: -1)
        } catch {
            print("❌ Failed to load GIF: \(error)")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            print("🕒 Timer (from viewDidLoad) done, proceeding to next screen")
            self.sceneDelegate?.proceedAfterSplashScreen()
        }
    }

    

}
