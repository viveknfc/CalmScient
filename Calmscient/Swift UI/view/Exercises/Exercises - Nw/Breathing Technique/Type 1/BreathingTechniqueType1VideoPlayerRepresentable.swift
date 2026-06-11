//
//  BreathingTechniqueType1VideoPlayerRepresentable.swift
//  Calmscient
//
//  UIKit bridge for AVPlayerLayer in the 4-7-8 breathing video section.
//
//  Vivek
//  20 May 2026
//

import AVFoundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
struct BreathingTechniqueType1VideoPlayerRepresentable: UIViewRepresentable {

    let player: AVPlayer

    func makeUIView(context: Context) -> BreathingTechniqueType1PlayerContainerView {
        let view = BreathingTechniqueType1PlayerContainerView()
        view.configure(player: player)
        return view
    }

    func updateUIView(_ uiView: BreathingTechniqueType1PlayerContainerView, context: Context) {
        uiView.setNeedsLayout()
    }
}

@available(iOS 16.0, *)
final class BreathingTechniqueType1PlayerContainerView: UIView {

    private var playerLayer: AVPlayerLayer?

    func configure(player: AVPlayer) {
        playerLayer?.removeFromSuperlayer()
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspect
        self.layer.addSublayer(layer)
        playerLayer = layer
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Video player layer") {
    let url = URL(string: "https://media.calmscient.in/uploads/exercises-videos/4-7-8Breathing.mp4")!
    return BreathingTechniqueType1VideoPlayerRepresentable(player: AVPlayer(url: url))
        .frame(height: 220)
        .padding()
}
#endif
