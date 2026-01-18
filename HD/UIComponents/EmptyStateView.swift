import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle = actionTitle, let action = action {
                PrimaryButton(title: actionTitle, action: action)
                    .padding(.top, 8)
            }
        }
        .padding(40)
    }
}

#Preview {
    VStack(spacing: 40) {
        EmptyStateView(
            icon: "figure.hiking",
            title: "No Hikes Yet",
            message: "Start your first hike to begin your journey"
        )

        EmptyStateView(
            icon: "photo",
            title: "No Photos",
            message: "Add photos to capture your memories",
            actionTitle: "Add Photo",
            action: {}
        )
    }
}
