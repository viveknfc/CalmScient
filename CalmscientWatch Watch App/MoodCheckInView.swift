//
//  MoodCheckInView.swift
//  CalmscientWatch Watch App
//
//  Lets the user log how they feel with one tap; the check-in is sent
//  to the iPhone via WatchConnectivity.
//
//  11 August 2026
//

import SwiftUI

struct MoodCheckInView: View {

    @EnvironmentObject private var connectivity: WatchConnectivityManager
    @Environment(\.dismiss) private var dismiss

    @State private var confirmed: WearableMood?

    var body: some View {
        ScrollView {
            if let confirmed {
                VStack(spacing: 8) {
                    Text(confirmed.emoji).font(.system(size: 44))
                    Text("Logged: \(confirmed.title)")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
            } else {
                VStack(spacing: 10) {
                    Text("How are you feeling?")
                        .font(.headline)
                        .multilineTextAlignment(.center)

                    ForEach(WearableMood.allCases) { mood in
                        Button {
                            log(mood)
                        } label: {
                            HStack {
                                Text(mood.emoji)
                                Text(mood.title)
                                Spacer()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Mood")
    }

    private func log(_ mood: WearableMood) {
        let checkIn = WearableMoodCheckIn(mood: mood, loggedAt: Date().timeIntervalSince1970)
        connectivity.sendMoodCheckIn(checkIn)
        withAnimation { confirmed = mood }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { dismiss() }
    }
}

#Preview {
    MoodCheckInView()
        .environmentObject(WatchConnectivityManager.shared)
}
