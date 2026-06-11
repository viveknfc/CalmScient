//
//  WeeklySummaryGraphDateRangeHeaderView.swift
//  Calmscient
//
//  Date range row for weekly summary graphs (parity with `ChartViewHeaderTableCell`).
//
//  Vivek
//  18 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct WeeklySummaryGraphDateRangeHeaderView: View {

    let dateRangeText: String
    let onCalendarTap: () -> Void

    var body: some View {
            
            Button(action: onCalendarTap) {
                HStack (spacing: 15) {
                    Image("calendarIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    
                    Text(dateRangeText)
                        .font(.custom(Fonts().lexendRegular, size: 14))
                        .foregroundStyle(Color.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .contentShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .frame(height: 60)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Date range header") {
    WeeklySummaryGraphDateRangeHeaderView(
        dateRangeText: "05/12/2026 - 05/18/2026",
        onCalendarTap: {}
    )
}
#endif
