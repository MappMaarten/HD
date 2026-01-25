//
//  HDPageIndicator.swift
//  HD
//
//  Custom page indicator with oval active state
//

import SwiftUI

struct HDPageIndicator: View {
    let totalPages: Int
    let currentPage: Int

    private let activeWidth: CGFloat = 24
    private let inactiveWidth: CGFloat = 8
    private let height: CGFloat = 8
    private let spacing: CGFloat = 8

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<totalPages, id: \.self) { index in
                if index == currentPage {
                    Capsule()
                        .fill(HDColors.forestGreen)
                        .frame(width: activeWidth, height: height)
                } else {
                    Circle()
                        .fill(HDColors.sageGreen)
                        .frame(width: inactiveWidth, height: height)
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: currentPage)
    }
}

#Preview {
    VStack(spacing: 40) {
        HDPageIndicator(totalPages: 7, currentPage: 0)
        HDPageIndicator(totalPages: 7, currentPage: 3)
        HDPageIndicator(totalPages: 7, currentPage: 6)
        HDPageIndicator(totalPages: 3, currentPage: 1)
    }
    .padding()
    .background(HDColors.cream)
}
