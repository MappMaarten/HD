import SwiftUI

struct CardView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    VStack(spacing: 16) {
        CardView {
            Text("This is a card")
        }

        CardView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Card Title")
                    .font(.headline)
                Text("Card content goes here")
                    .font(.body)
            }
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
