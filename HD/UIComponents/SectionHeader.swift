import SwiftUI

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    VStack(spacing: 24) {
        SectionHeader(title: "Section Title")

        SectionHeader(
            title: "Section with Subtitle",
            subtitle: "This is additional context"
        )
    }
    .padding()
}
