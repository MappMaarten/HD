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
    var showPulse: Bool = false

    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.8

    var body: some View {
        ZStack {
            // Pulsating circle (behind the button)
            if showPulse {
                Circle()
                    .stroke(HDColors.forestGreen.opacity(0.5), lineWidth: 3)
                    .frame(width: HDSpacing.fabSize, height: HDSpacing.fabSize)
                    .scaleEffect(pulseScale)
                    .opacity(pulseOpacity)
            }

            // Main button
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
        .onAppear {
            if showPulse {
                startPulseAnimation()
            }
        }
    }

    private func startPulseAnimation() {
        withAnimation(
            .easeInOut(duration: 2.5)
            .repeatForever(autoreverses: false)
        ) {
            pulseScale = 2.0
            pulseOpacity = 0.0
        }
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
