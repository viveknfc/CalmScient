//
//  SceneDelegate.swift
//  CalmscientIOS
//
//  Created by KA on 22/04/24.
//

import UIKit

@available(iOS 16.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var isSplashScreenShowing = false

    var window: UIWindow?
    func changeToUserInterfaceStyle(_ style: UIUserInterfaceStyle) {
        if let window = self.window {
            window.overrideUserInterfaceStyle = style
        }
    }
    func changeRootViewController(to viewController: UIViewController) {
        guard let window = self.window else { return }
        
        // Set the new root view controller
        window.rootViewController = viewController

    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }

        // Initialize the window
        window = UIWindow(windowScene: windowScene)
        let storyboard = UIStoryboard(name: "Taking Control Index", bundle: nil)
        print("📘 Storyboard loaded")
        let vc = storyboard.instantiateViewController(withIdentifier: "LaunchScreenVC")
        print("🧩 ViewController instantiated: \(vc)")

        if let splashVC = vc as? LaunchScreenVC {
            splashVC.sceneDelegate = self
            window?.rootViewController = splashVC
            window?.makeKeyAndVisible()
            isSplashScreenShowing = true
            print("🌟 Window made key and visible: \(window?.isKeyWindow == true)")
            print("✅ LaunchScreenVC set as root")
        } else {
            print("❌ Could not cast to LaunchScreenVC")
        }
  
        
        if let isDarkMode = UserDefaults.standard.value(forKey: "isDarkMode") as? Bool {
                let style: UIUserInterfaceStyle = isDarkMode ? .dark : .light
                changeToUserInterfaceStyle(style)
            }


    }
    
    //MARK: - Proceed after Splash screen
    
    func proceedAfterSplashScreen() {
        isSplashScreenShowing = false
        print("after 2 sec its printing")
        if (UserDefaults.standard.value(forKey: "rememberMe") as? Int == 1) {
            print("remember Me pressed before")
            
            let (loginDetails, tokenResponse) = UserDefaultsHelper.retrieveLoginDetailsFromUserDefaults()
            
            if let loginDetails = loginDetails, let tokenResponse = tokenResponse {
                // Populate shared info
                ApplicationSharedInfo.shared.loginResponse = loginDetails
                ApplicationSharedInfo.shared.tokenResponse = tokenResponse

                self.userStartUpAPICall()
            } else {
                // If no login details are found, navigate to Login screen
                navigateToLogin()
            }
        } else {
            // No rememberMe, go to LoginVC
            let homeController = UIStoryboard(name: "LoginVC", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            let navC = UINavigationController(rootViewController: homeController)
            navC.navigationBar.isHidden = true
            window?.rootViewController = navC
            window?.makeKeyAndVisible()
        }
    }
    
    //MARK: - First API Call if remember ME
    
    func userStartUpAPICall(retryCount: Int = 0) {
        
        guard let loginResponse = ApplicationSharedInfo.shared.loginResponse,
              let tokenResponse = ApplicationSharedInfo.shared.tokenResponse else {
            print("No login details found, navigating to login screen.")
            DispatchQueue.main.async {
                self.navigateToLogin()
            }
            return
        }

        
        let plId = loginResponse.patientLocationID
        let patientId = loginResponse.patientID
        let clientId = loginResponse.clientID
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate = dateFormatter.string(from: Date())

        let params: [String: Any] = [
            "patientLocationId": plId,
            "clientId": clientId,
            "patientId": patientId,
            "time": formattedDate
        ]

        print("Params for user startup API from scene delegate is :", params)
        
        if let rootVC = window?.rootViewController {
            APIService.userStartUpAPICalling(rootVC, params: params, method: "POST", accessToken: tokenResponse.accessToken, acces: false, parameterPlacement: "body") { response in
                DispatchQueue.main.async {
                    if let dictResponse = response as? [String: Any] {
                        self.handleUserStartUpResponse(response: dictResponse)
                    } else {
                        print("API call failed or timed out. Retry count: \(retryCount)")
                        if retryCount == 0 {
                            // Retry once
                            self.userStartUpAPICall(retryCount: 1)
                        } else {
                            // On second failure, go to dashboard
                            self.navigateToDashboard()
                        }
                    }
                }
            }
        }

    }
    
    //MARK: - User Mood Screen if Remember Me Response
    
    func handleUserStartUpResponse(response: [String: Any]) {
        print("the responsae from startup is", response)
        guard let responseMessage = response["saved"] as? Int else {
            print("Invalid response, navigating to default screen.")
            navigateToLogin()
            return
        }

        if responseMessage == 0 {
            navigateToUserIntro()
        } else {
            navigateToDashboard()
        }
    }

    //END
    
    //MARK: - Retry API Call Alert
    
    func showRetryAlert(on viewController: UIViewController, message: String = "The request timed out. Please try again.") {
        let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
            self.userStartUpAPICall()
        }))

        viewController.present(alert, animated: true, completion: nil)
    }
    
    //END
    
    func checkForSavedLogin() {
        let (loginDetails, tokenResponse) = UserDefaultsHelper.retrieveLoginDetailsFromUserDefaults()

        if let loginDetails = loginDetails, let tokenResponse = tokenResponse {
            // Populate shared info
            ApplicationSharedInfo.shared.loginResponse = loginDetails
            ApplicationSharedInfo.shared.tokenResponse = tokenResponse

        }
    }



    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background. 
        
        if isSplashScreenShowing {
            print("⏳ Skipping login check — splash screen is still showing")
            return
        }
        
        let (loginDetails, tokenResponse) = UserDefaultsHelper.retrieveLoginDetailsFromUserDefaults()

        if let loginDetails = loginDetails, let tokenResponse = tokenResponse {
            // Populate shared info
            ApplicationSharedInfo.shared.loginResponse = loginDetails
            ApplicationSharedInfo.shared.tokenResponse = tokenResponse

            if TimeZoneHelper.isTimeZoneChanged() {
                print("Time zone has changed. Navigating to UserIntroDayFeedbackViewController")
                navigateToUserIntro()
            }
            

        }
        else {
            // If no login details are found, navigate to Login screen
            navigateToLogin()
        }
            

    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    
    func changeRootViewControllerToTabBar() {
            guard let window = self.window else { return }
            let homeController = UIStoryboard(name: "AppTabBar", bundle: nil).instantiateViewController(withIdentifier: "AppMainTabViewController") as! AppMainTabViewController

            
            window.rootViewController = homeController
            window.makeKeyAndVisible()
            
            let options: UIView.AnimationOptions = .transitionFlipFromRight
            UIView.transition(with: window, duration: 0.5, options: options, animations: nil, completion: nil)
        }
    
    private func navigateToUserIntro() {
        guard let window = self.window else {
            print("❌ Window is nil, cannot navigate to User Intro")
            return
        }

        let storyboard = UIStoryboard(name: "UserIntro", bundle: nil)
        if let homeController = storyboard.instantiateViewController(withIdentifier: "UserIntroDayFeedbackViewController") as? UserIntroDayFeedbackViewController {
            
            let navC = UINavigationController(rootViewController: homeController)

            // ✅ Smooth transition from splash screen to User Intro
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                window.rootViewController = navC
            })
        } else {
            print("❌ Failed to load UserIntroDayFeedbackViewController")
        }
    }
    
    private func navigateToLogin() {
        guard let window = self.window else {
            print("❌ Window is nil, cannot navigate to Login")
            return
        }

        let storyboard = UIStoryboard(name: "LoginVC", bundle: nil)
        if let homeController = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
            
            let navC = UINavigationController(rootViewController: homeController)
            navC.navigationBar.isHidden = true

            // ✅ Smooth transition to Login screen
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                window.rootViewController = navC
            })
        } else {
            print("❌ Failed to load LoginVC")
        }
    }

    
    private func navigateToDashboard() {
        guard let window = self.window else {
            print("❌ Window is nil, cannot navigate to dashboard")
            return
        }

        let storyboard = UIStoryboard(name: "AppTabBar", bundle: nil)
        if let homeController = storyboard.instantiateViewController(withIdentifier: "AppMainTabViewController") as? AppMainTabViewController {
            
            homeController.isInitalView = false
            let navC = UINavigationController(rootViewController: homeController)
            navC.navigationBar.isHidden = true

            // ✅ Smooth transition from splash screen to dashboard
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                window.rootViewController = navC
            })
        } else {
            print("❌ Failed to load AppMainTabViewController")
        }
    }

    
}

