//
//  FloatingActionButton.swift
//  HD
//
//  Large floating action button (FAB) for primary actions
//

import SwiftUI

struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2.weight(.medium))
                .foregroundColor(.white)
                .frame(width: HDSpacing.fabSize, height: HDSpacing.fabSize)
                .background(HDColors.forestGreen)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        HDColors.cream.ignoresSafeArea()

        VStack {
            Spacer()
            HStack {
                Spacer()
                FloatingActionButton(icon: "plus") {
                    print("FAB tapped")
                }
            }
        }
        .padding(.trailing, HDSpacing.fabMargin)
        .padding(.bottom, HDSpacing.fabMargin)
    }
}
