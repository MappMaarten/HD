import Foundation
import SwiftData

@Model
final class LAWRoute {
    // MARK: - Properties (Met default waarden voor CloudKit)
    var id: UUID = UUID()
    var name: String = ""
    var stagesCount: Int = 0
    var sortOrder: Int = 0

    // MARK: - Initializer
    init(
        id: UUID = UUID(),
        name: String = "",
        stagesCount: Int = 0,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.stagesCount = stagesCount
        self.sortOrder = sortOrder
    }
}
