//
//  DateBlock.swift
//  HD
//
//  Handwritten-style date display - journal/notebook aesthetic
//

import SwiftUI

struct DateBlock: View {
    let date: Date

    private var weekdayShort: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "nl_NL")
        formatter.dateFormat = "EE"
        return formatter.string(from: date).lowercased()
    }

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    private var monthAbbreviation: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "nl_NL")
        formatter.dateFormat = "MMM"
        return formatter.string(from: date).lowercased()
    }

    var body: some View {
        VStack(spacing: 2) {
            // Weekday (small handwritten)
            Text(weekdayShort)
                .font(.custom(HDTypography.handwrittenFont, size: 10))
                .foregroundColor(HDColors.mutedGreen)

            // Day number (large handwritten)
            Text(dayNumber)
                .font(.custom(HDTypography.handwrittenFont, size: 24))
                .foregroundColor(HDColors.forestGreen)

            // Month (small handwritten)
            Text(monthAbbreviation)
                .font(.custom(HDTypography.handwrittenFont, size: 12))
                .foregroundColor(HDColors.mutedGreen)
        }
        .frame(minWidth: 33, maxWidth: 33)  // Force consistent width
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(HDColors.sageGreen.opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(HDColors.mutedGreen.opacity(0.25), lineWidth: 1)
        )
    }
}

#Preview {
    HStack(spacing: HDSpacing.md) {
        DateBlock(date: Date())
        DateBlock(date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!)
        DateBlock(date: Calendar.current.date(byAdding: .month, value: -1, to: Date())!)
    }
    .padding(HDSpacing.horizontalMargin)
    .background(HDColors.cream)
}
