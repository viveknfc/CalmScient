//
//  SuccessAlertPresenter.swift
//  Calmscient
//
//  Shared success alert presentation (configuration + window presentation + UIViewController helpers).
//

//  Vivek
//  15 May 2026
//
import UIKit

/// Content for ``SuccessAlertView``; pass only the fields you need. Button title defaults to localized `"Ok"` when nil.
struct SuccessAlertConfiguration {
    /// When non-nil, replaces the nib placeholder message.
    var message: String?
    var centreImage: UIImage?
    /// Used when ``centreImage`` is nil; loads ``UIImage(named:)``.
    var centreImageAssetName: String?
    /// When nil, ``AppHelper.getLocalizeString(str: "Ok")`` is applied.
    var okButtonTitle: String?

    init(
        message: String? = nil,
        centreImage: UIImage? = nil,
        centreImageAssetName: String? = nil,
        okButtonTitle: String? = nil
    ) {
        self.message = message
        self.centreImage = centreImage
        self.centreImageAssetName = centreImageAssetName
        self.okButtonTitle = okButtonTitle
    }
}

enum SuccessAlertPresenter {

    /// Tag on the dimming view so a new presentation can replace any existing one.
    static let dimmingViewTag = 999

    /// Presents ``SuccessAlertView`` over the first connected window. Use from view models when there is no suitable ``UIViewController``.
    static func present(
        configuration: SuccessAlertConfiguration = SuccessAlertConfiguration(),
        okButtonAction: (() -> Void)? = nil
    ) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }

        window.subviews.filter { $0.tag == dimmingViewTag }.forEach { $0.removeFromSuperview() }

        let dimmingView = UIView(frame: window.bounds)
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dimmingView.alpha = 0
        dimmingView.tag = dimmingViewTag

        let alertWidth = UIScreen.main.bounds.width - 80
        let alertView = SuccessAlertView(frame: CGRect(x: 0, y: 0, width: alertWidth, height: 0))

        if let content = configuration.message {
            alertView.successContent.text = content
        }

        let okTitle = configuration.okButtonTitle ?? AppHelper.getLocalizeString(str: "Ok")
        alertView.okButton.setTitle(okTitle, for: .normal)

        if let image = configuration.centreImage {
            alertView.centreImage.image = image
        } else if let name = configuration.centreImageAssetName, let image = UIImage(named: name) {
            alertView.centreImage.image = image
        }

        alertView.layoutIfNeeded()
        let requiredHeight = alertView.calculateRequiredHeight()
        alertView.frame.size.height = requiredHeight
        alertView.center = window.center

        alertView.okButtonAction = {
            UIView.animate(withDuration: 0.3, animations: {
                dimmingView.alpha = 0
                alertView.alpha = 0
            }, completion: { _ in
                dimmingView.removeFromSuperview()
                alertView.removeFromSuperview()
            })
            okButtonAction?()
        }

        window.addSubview(dimmingView)
        window.addSubview(alertView)
        alertView.center = window.center

        UIView.animate(withDuration: 0.3) {
            dimmingView.alpha = 1
            alertView.alpha = 1
        }
    }
}

extension UIViewController {

    /// Presents the shared success alert using a configuration object (message, image, OK title).
    func showSuccessAlert(configuration: SuccessAlertConfiguration, okButtonAction: (() -> Void)? = nil) {
        SuccessAlertPresenter.present(configuration: configuration, okButtonAction: okButtonAction)
    }

    /// Parameter convenience; forwards to ``SuccessAlertPresenter``.
    func showSuccessAlert(
        successContent: String? = nil,
        centreImage: UIImage? = nil,
        okButtonTitle: String? = nil,
        okButtonAction: (() -> Void)? = nil
    ) {
        let configuration = SuccessAlertConfiguration(
            message: successContent,
            centreImage: centreImage,
            okButtonTitle: okButtonTitle
        )
        SuccessAlertPresenter.present(configuration: configuration, okButtonAction: okButtonAction)
    }
}
