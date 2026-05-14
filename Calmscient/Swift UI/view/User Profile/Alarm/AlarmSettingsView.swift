//
//  AlarmSettingsView.swift
//  Calmscient
//
//  SwiftUI alarm interval sheet (matches design: header, subtitle, interval list).
//
//  NFC Solutions
//  14 May 2026
//
import SwiftUI

struct AlarmSettingsView: View {
    @ObservedObject var viewModel: AlarmSettingsViewModel

    private let circleSize: CGFloat = 30
    private let iconPointSize: CGFloat = 12

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)

            Text("Alarm settings subtitle".localized)
                .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                .foregroundStyle(Color.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
                .padding(.bottom, 16)

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(AlarmSettingsViewModel.allowedMinutes, id: \.self) { minutes in
                        optionRow(minutes: minutes)
                        if minutes != AlarmSettingsViewModel.allowedMinutes.last {
                            Divider()
                                .background(Color(red: 0.9, green: 0.9, blue: 0.92))
                        }
                    }
                }
            }
        }
        .background(Color.white)
    }

    private var header: some View {
        ZStack {
            HStack {
                headerIconButton(systemName: "xmark") {
                    viewModel.cancel()
                }
                Spacer()
                headerIconButton(systemName: "checkmark") {
                    viewModel.confirm()
                }
                .disabled(viewModel.isSubmitting)
                .opacity(viewModel.isSubmitting ? 0.45 : 1)
            }

            Text("Alarm settings".localized)
                .font(LoginDesignSystem.Typography.lexendRegular(size: 16))
                .foregroundStyle(Color.primary)
        }
    }

    private func headerIconButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: iconPointSize, weight: .semibold))
                .foregroundStyle(LoginDesignSystem.ColorName.purpleDeep)
                .frame(width: circleSize, height: circleSize)
                .background(
                    Circle()
                        .fill(LoginDesignSystem.ColorName.lavenderWave)
                )
        }
        .buttonStyle(.plain)
    }

    private func optionRow(minutes: Int) -> some View {
        let isSelected = viewModel.selectedMinutes == minutes
        return Button {
            viewModel.select(minutes: minutes)
        } label: {
            HStack {
                Text(viewModel.rowLabel(minutes: minutes))
                    .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                    .foregroundStyle(Color.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(LoginDesignSystem.ColorName.purpleDeep)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
#Preview("Alarm settings") {
    AlarmSettingsView(viewModel: AlarmSettingsViewModel(initialAlarmMinutes: 15))
}
#endif
