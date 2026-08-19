//
//  ExercisesTabView.swift
//  Calmscient
//
//  Native SwiftUI Exercises tab — replaces `MainTabStoryboardHost` for this tab.
//
//  Each destination owns its view model via `@StateObject` (so it survives redraws,
//  the way the hosting controller used to) and wires the navigation closures. The
//  view models keep their UIKit push/pop fallback, which is what the Home ▸ favourites
//  path (`ExcercisesTypeEnum.destVC`) still uses — those hosting controllers stay.
//
//  Chrome parity with the retired hosting controllers:
//   • `navigationItem.title = viewModel.screenTitle` → `.navigationTitle(...)`, inline.
//   • the custom `MedicationNavigationBackButton` leading item → same SwiftUI view in
//     a `.navigationBarLeading` toolbar item, with the system back button hidden.
//   • `viewWillAppear → viewModel.onHostWillAppear()` → `.onAppear`.
//   • screens with media also had `viewDidLoad → onHostViewDidLoad()` and
//     `viewWillDisappear → onHostWillDisappear()` → `.onAppear` / `.onDisappear`.
//

import SwiftUI

@available(iOS 16.0, *)
struct ExercisesTabView: View {

    let navigationTitle: String

    @State private var path: [ExercisesRoute] = []
    @StateObject private var viewModel = ExercisesViewModel()

    var body: some View {
        NavigationStack(path: $path) {
            ExercisesView(viewModel: viewModel)
                .navigationTitle(navigationTitle)
                .navigationBarTitleDisplayMode(.inline)
                .appNavigationBarChrome()
                .onAppear {
                    viewModel.onOpenRoute = { path.append($0) }
                    viewModel.onHostWillAppear()
                }
                .navigationDestination(for: ExercisesRoute.self) { route in
                    destination(for: route)
                }
        }
    }

    @ViewBuilder
    private func destination(for route: ExercisesRoute) -> some View {
        switch route {
        case .mindfulness:            MindfulnessRoute(path: $path)
        case .progressive:            ProgressiveRoute(path: $path)
        case .touchButterflyIntro:    TouchButterflyIntroRoute(path: $path)
        case .touchButterflyHowTo:    TouchButterflyHowToRoute(path: $path)
        case .handOverYourHeart:      HandOverYourHeartRoute(path: $path)
        case .mindfulWalking:         MindfulWalkingRoute(path: $path)
        case .movementDance:          MovementDanceRoute(path: $path)
        case .movementRunning:        MovementRunningRoute(path: $path)
        case .mindfulBodyMovement:    MindfulBodyMovementRoute(path: $path)
        case .breathingTechnique:     BreathingTechniqueRoute(path: $path)
        case .breathingType1:         BreathingType1Route(path: $path)
        case .mindfulBreathing:       MindfulBreathingRoute(path: $path)
        case .diaphragmaticBreathing: DiaphragmaticBreathingRoute(path: $path)
        }
    }
}

// MARK: - Shared chrome

@available(iOS 16.0, *)
private struct ExerciseScreenChrome: ViewModifier {
    let title: String
    let onBack: () -> Void

    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    MedicationNavigationBackButton(onBack: onBack)
                }
            }
            .appNavigationBarChrome()
    }
}

@available(iOS 16.0, *)
private extension View {
    func exerciseScreenChrome(title: String, onBack: @escaping () -> Void) -> some View {
        modifier(ExerciseScreenChrome(title: title, onBack: onBack))
    }
}

// MARK: - Destinations

@available(iOS 16.0, *)
private struct MindfulnessRoute: View {
    @Binding var path: [ExercisesRoute]
    @StateObject private var viewModel = MindfulnessViewModel()
    var body: some View {
        MindfulnessView(viewModel: viewModel)
            .exerciseScreenChrome(title: viewModel.screenTitle) { viewModel.openBack() }
            .onAppear {
                viewModel.onClose = { if !path.isEmpty { path.removeLast() } }
                viewModel.onHostWillAppear()
            }
    }
}

@available(iOS 16.0, *)
private struct ProgressiveRoute: View {
    @Binding var path: [ExercisesRoute]
    @StateObject private var viewModel = ProgressiveViewModel()
    var body: some View {
        ProgressiveView(viewModel: viewModel)
            .exerciseScreenChrome(title: viewModel.screenTitle) { viewModel.openBack() }
            .onAppear {
                viewModel.onClose = { if !path.isEmpty { path.removeLast() } }
                viewModel.onHostViewDidLoad()
                viewModel.onHostWillAppear()
            }
            .onDisappear { viewModel.onHostWillDisappear() }
    }
}

@available(iOS 16.0, *)
private struct TouchButterflyIntroRoute: View {
    @Binding var path: [ExercisesRoute]
    @StateObject private var viewModel = TouchButterflyHugViewModel()
    var body: some View {
        TouchButterflyIntroView(viewModel: viewModel)
            .exerciseScreenChrome(title: viewModel.screenTitle) { viewModel.openBack() }
            .onAppear {
                viewModel.onOpenRoute = { path.append($0) }
                viewModel.onClose = { if !path.isEmpty { path.removeLast() } }
                viewModel.onCloseToRoot = { path.removeAll() }
                viewModel.onHostWillAppear()
            }
    }
}

@available(iOS 16.0, *)
private struct TouchButterflyHowToRoute: View {
    @Binding var path: [ExercisesRoute]
    @StateObject private var viewModel = TouchButterflyHugViewModel()
    var body: some View {
        TouchButterflyHowToView(viewModel: viewModel)
            .exerciseScreenChrome(title: viewModel.screenTitle) { viewModel.openBack() }
            .onAppear {
                viewModel.onClose = { if !path.isEmpty { path.removeLast() } }
                viewModel.onCloseToRoot = { path.removeAll() }
                viewModel.onHostWillAppear()
            }
    }
}

@available(iOS 16.0, *)
private struct HandOverYourHeartRoute: View {
    @Binding var path: [ExercisesRoute]
    @StateObject private var viewModel = HandOverYourHeartViewModel()
    var body: some View {
        HandOverYourHeartView(viewModel: viewModel)
            .exerciseScreenChrome(title: viewModel.screenTitle) { viewModel.openBack() }
            .onAppear {
                viewModel.onClose = { if !path.isEmpty { path.removeLast() } }
                viewModel.onHostWillAppear()
            }
    }
}

@available(iOS 16.0, *)
private struct MindfulWalkingRoute: View {
    @Binding var path: [ExercisesRoute]
    @StateObject private var viewModel = MindfulWalkingViewModel()
    var body: some View {
        MindfulWalkingView(viewModel: viewModel)
            .exerciseScreenChrome(title: viewModel.screenTitle) { viewModel.openBack() }
            .onAppear {
                viewModel.onClose = { if !path.isEmpty { path.removeLast() } }
                viewModel.onHostViewDidLoad()
                viewModel.onHostWillAppear()
            }
            .onDisappear { viewModel.onHostWillDisappear() }
    }
}

@available(iOS 16.0, *)
private struct MovementDanceRoute: View {
    @Binding var path: [ExercisesRoute]
    @StateObject private var viewModel = MovementDanceViewModel()
    var body: some View {
        MovementDanceView(viewModel: viewModel)
            .exerciseScreenChrome(title: viewModel.screenTitle) { viewModel.openBack() }
            .onAppear {
                viewModel.onClose = { if !path.isEmpty { path.removeLast() } }
                viewModel.onHostWillAppear()
            }
    }
}

@available(iOS 16.0, *)
private struct MovementRunningRoute: View {
    @Binding var path: [ExercisesRoute]
    @StateObject private var viewModel = MovementRunningViewModel()
    var body: some View {
        MovementRunningView(viewModel: viewModel)
            .exerciseScreenChrome(title: viewModel.screenTitle) { viewModel.openBack() }
            .onAppear {
                viewModel.onClose = { if !path.isEmpty { path.removeLast() } }
                viewModel.onHostWillAppear()
            }
    }
}

@available(iOS 16.0, *)
private struct MindfulBodyMovementRoute: View {
    @Binding var path: [ExercisesRoute]
    @StateObject private var viewModel = MindfulBodyMovementViewModel()
    var body: some View {
        MindfulBodyMovementView(viewModel: viewModel)
            .exerciseScreenChrome(title: viewModel.screenTitle) { viewModel.openBack() }
            .onAppear {
                viewModel.onClose = { if !path.isEmpty { path.removeLast() } }
                viewModel.onHostWillAppear()
            }
    }
}

@available(iOS 16.0, *)
private struct BreathingTechniqueRoute: View {
    @Binding var path: [ExercisesRoute]
    @StateObject private var viewModel = BreathingTechniqueViewModel()
    var body: some View {
        BreathingTechniqueView(viewModel: viewModel)
            .exerciseScreenChrome(title: viewModel.screenTitle) { viewModel.openBack() }
            .onAppear {
                viewModel.onOpenRoute = { path.append($0) }
                viewModel.onClose = { if !path.isEmpty { path.removeLast() } }
                viewModel.onHostWillAppear()
            }
    }
}

@available(iOS 16.0, *)
private struct BreathingType1Route: View {
    @Binding var path: [ExercisesRoute]
    @StateObject private var viewModel = BreathingTechniqueType1ViewModel()
    var body: some View {
        BreathingTechniqueType1View(viewModel: viewModel)
            .exerciseScreenChrome(title: viewModel.screenTitle) { viewModel.openBack() }
            .onAppear {
                viewModel.onClose = { if !path.isEmpty { path.removeLast() } }
                viewModel.onHostViewDidLoad()
                viewModel.onHostWillAppear()
            }
            .onDisappear { viewModel.onHostWillDisappear() }
    }
}

@available(iOS 16.0, *)
private struct MindfulBreathingRoute: View {
    @Binding var path: [ExercisesRoute]
    @StateObject private var viewModel = MindfulBreathingViewModel()
    var body: some View {
        MindfulBreathingView(viewModel: viewModel)
            .exerciseScreenChrome(title: viewModel.screenTitle) { viewModel.openBack() }
            .onAppear {
                viewModel.onClose = { if !path.isEmpty { path.removeLast() } }
                viewModel.onHostViewDidLoad()
                viewModel.onHostWillAppear()
            }
            .onDisappear { viewModel.onHostWillDisappear() }
    }
}

@available(iOS 16.0, *)
private struct DiaphragmaticBreathingRoute: View {
    @Binding var path: [ExercisesRoute]
    @StateObject private var viewModel = DiaphragmaticBreathingViewModel()
    var body: some View {
        DiaphragmaticBreathingView(viewModel: viewModel)
            .exerciseScreenChrome(title: viewModel.screenTitle) { viewModel.openBack() }
            .onAppear {
                viewModel.onClose = { if !path.isEmpty { path.removeLast() } }
                viewModel.onHostViewDidLoad()
                viewModel.onHostWillAppear()
            }
            .onDisappear { viewModel.onHostWillDisappear() }
    }
}
