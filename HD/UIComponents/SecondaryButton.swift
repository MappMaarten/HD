import SwiftUI

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.clear)
                .foregroundColor(isEnabled ? Color.accentColor : Color.gray)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isEnabled ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: 2)
                )
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    VStack(spacing: 16) {
        SecondaryButton(title: "Skip") {}
        SecondaryButton(title: "Disabled", action: {}, isEnabled: false)
    }
    .padding()
}
