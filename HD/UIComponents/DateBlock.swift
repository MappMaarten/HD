//
//  DateBlock.swift
//  HD
//
//  Compact date display block showing weekday, day number, and month
//

import SwiftUI

struct DateBlock: View {
    let date: Date

    private var weekdayAbbreviation: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "nl_NL")
        formatter.dateFormat = "EE"
        return formatter.string(from: date).uppercased()
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
        return formatter.string(from: date).uppercased()
    }

    var body: some View {
        VStack(spacing: 2) {
            Text(weekdayAbbreviation)
                .font(.caption2.weight(.medium))
                .foregroundColor(HDColors.mutedGreen)
            Text(dayNumber)
                .font(.title2.weight(.bold))
                .foregroundColor(HDColors.forestGreen)
            Text(monthAbbreviation)
                .font(.caption2.weight(.medium))
                .foregroundColor(HDColors.mutedGreen)
        }
        .frame(width: 44)
        .padding(.vertical, HDSpacing.sm)
        .background(HDColors.sageGreen.opacity(0.7))
        .cornerRadius(HDSpacing.cornerRadiusSmall)
        .overlay(
            RoundedRectangle(cornerRadius: HDSpacing.cornerRadiusSmall)
                .stroke(HDColors.mutedGreen.opacity(0.2), lineWidth: 1)
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
