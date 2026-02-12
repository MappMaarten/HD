//
//  ListMapToggle.swift
//  HD
//
//  Pill-shaped toggle for switching between list and map views
//

import SwiftUI

struct ListMapToggle: View {
    @Binding var showMap: Bool

    var body: some View {
        HStack(spacing: 0) {
            toggleButton(icon: "list.bullet", isSelected: !showMap) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showMap = false
                }
            }
            toggleButton(icon: "map", isSelected: showMap) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showMap = true
                }
            }
        }
        .padding(4)
        .background(HDColors.sageGreen)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(HDColors.mutedGreen.opacity(0.3), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.08), radius: 4, y: 2)
    }

    private func toggleButton(icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : HDColors.forestGreen)
                .frame(width: 36, height: 32)
                .background(isSelected ? HDColors.forestGreen : Color.clear)
                .clipShape(Capsule())
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: HDSpacing.lg) {
        ListMapToggle(showMap: .constant(false))
        ListMapToggle(showMap: .constant(true))
    }
    .padding(HDSpacing.horizontalMargin)
    .background(HDColors.cream)
}
