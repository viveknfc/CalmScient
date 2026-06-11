//
//  LaunchGifRepresentable.swift
//  Calmscient
//
//  SwiftyGif bridge for splash animated logo (parity with storyboard UIImageView).
//
//  Vivek
//  27 May 2026
//
import SwiftUI
import SwiftyGif
import UIKit

/// Hosts the GIF image view and keeps it scaled to the SwiftUI-assigned bounds.
private final class LaunchGifContainerView: UIView {
    let imageView = UIImageView()
    private var didLoadGif = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        clipsToBounds = true

        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        addSubview(imageView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }

    func loadGifIfNeeded() {
        guard !didLoadGif else { return }
        didLoadGif = true
        do {
            print("🎬 Loading GIF in LaunchGifRepresentable")
            let gif = try UIImage(gifName: "whiteGif.gif")
            imageView.setGifImage(gif, loopCount: -1)
        } catch {
            didLoadGif = false
            print("❌ Failed to load GIF: \(error)")
        }
    }
}

struct LaunchGifRepresentable: UIViewRepresentable {

    func makeUIView(context: Context) -> UIView {
        let container = LaunchGifContainerView()
        container.loadGifIfNeeded()
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        (uiView as? LaunchGifContainerView)?.loadGifIfNeeded()
    }
}
