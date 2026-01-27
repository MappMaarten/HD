import Foundation
import SwiftData

@Model
final class HikeType {
    var id: UUID = UUID()
    var name: String = ""
    var iconName: String = "figure.walk" // Een veilige default SF Symbol
    var sortOrder: Int = 0

    init(
        id: UUID = UUID(),
        name: String = "",
        iconName: String = "figure.walk",
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.sortOrder = sortOrder
    }
}
