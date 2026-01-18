import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isEnabled ? Color.accentColor : Color.gray.opacity(0.3))
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Continue") {}
        PrimaryButton(title: "Disabled", action: {}, isEnabled: false)
    }
    .padding()
}
