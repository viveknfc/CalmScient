//
//  NeedToTalkProviderCardView.swift
//  Calmscient
//
//  Provider header card for the emergency resources screen.
//
//  Storyboard parity (view MI3-ez-fSN): 106pt tall band filled with `needToTalkBack`,
//  70×70 `docpic` image inset 26pt from the leading edge and 18pt from the top, and a
//  name / location / phone stack starting 31pt after the image.
//

import SwiftUI

@available(iOS 16.0, *)
struct NeedToTalkProviderCardView: View {

    let provider: NeedToTalkProviderPresentation
    let onPhoneTap: () -> Void

    /// Same reference the storyboard used (`image="docpic.png"`). `UIImage(named:)`
    /// caches, so resolving this per render costs nothing.
    private var providerImage: UIImage {
        UIImage(named: "docpic.png") ?? UIImage(named: "docpic") ?? UIImage()
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color("needToTalkBack")

            HStack(alignment: .top, spacing: 31) {
                // `docpic.png` is a loose bundle resource, not an asset-catalog imageset.
                // SwiftUI's string-named Image only reads asset catalogs, so it resolved
                // to nothing and the card rendered with an empty gap. The storyboard
                // referenced it by filename through `UIImage(named:)`, which does fall
                // back to bundle files — so go through that.
                Image(uiImage: providerImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70, height: 70)

                VStack(alignment: .leading, spacing: 0) {
                    // Lexend-Medium 20, `blackAndWhite` (font applied in legacy viewDidLoad).
                    Text(provider.name)
                        .font(.custom(Fonts().lexendMedium, size: 20))
                        .foregroundColor(Color("blackAndWhite"))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(height: 21, alignment: .leading)

                    // Lexend-Bold 12, `AppointmentsTextColor`, 3pt below the name.
                    Text(provider.location)
                        .font(.custom(Fonts().lexendBold, size: 12))
                        .foregroundColor(Color("AppointmentsTextColor"))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(height: 16, alignment: .leading)
                        .padding(.top, 3)

                    // Lexend-Medium 17, `blueAndPink`, 5pt below the location, tappable.
                    Text(provider.phoneNumber)
                        .font(.custom(Fonts().lexendMedium, size: 17))
                        .foregroundColor(Color("blueAndPink"))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(height: 21, alignment: .leading)
                        .padding(.top, 5)
                        .contentShape(Rectangle())
                        .onTapGesture(perform: onPhoneTap)

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.trailing, 29)
            }
            .padding(.leading, 26)
            .padding(.top, 18)
        }
        .frame(height: 106)
        .frame(maxWidth: .infinity)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Provider card") {
    NeedToTalkProviderCardView(
        provider: NeedToTalkProviderPresentation(
            name: "Dr. Jane Doe",
            location: "Springfield General Hospital",
            phoneNumber: "(555) 123-4567"
        ),
        onPhoneTap: {}
    )
}
#endif
