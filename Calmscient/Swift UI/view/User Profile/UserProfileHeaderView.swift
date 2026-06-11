//
//  UserProfileHeaderView.swift
//  Calmscient
//
//  Avatar, gallery affordance, and version label.
//
//  Vivek
//  14 May 2026
//
import SwiftUI
import UIKit

struct UserProfileHeaderView: View {
    let profileImage: UIImage?
    let versionText: String
    let onGalleryTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if let ui = profileImage {
                        Image(uiImage: ui)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image("profileIcon")
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color(hex: "#6E6BB3"), lineWidth: 2)
                )

                Button(action: onGalleryTap) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                        Image("galleryIcon")
                            .resizable()
                            .scaledToFit()
                            .padding(6)
                    }
                    .frame(width: 39, height: 39)
                }
                .offset(x: 8, y: 8)
            }
            .padding(.top, 24)

            HStack {
                Spacer()
                Text(versionText)
                    .font(.custom(Fonts().lexendLight, size: 14))
                    .foregroundColor(Color("424242Color"))
                    .padding(.trailing, 16)
            }
            .padding(.top, 4)
        }
    }
}

#if DEBUG
#Preview("Profile header") {
    UserProfileHeaderView(
        profileImage: nil,
        versionText: "Version 1.0.1",
        onGalleryTap: {}
    )
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

#Preview("Profile header (photo)") {
    UserProfileHeaderView(
        profileImage: UIImage(systemName: "person.crop.circle.fill"),
        versionText: "Version 1.0.5",
        onGalleryTap: {}
    )
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
#endif
