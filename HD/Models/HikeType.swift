import Foundation
import SwiftData
import SwiftUI

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

// MARK: - Display Color Extension

extension HikeType {
    var displayColor: Color {
        let type = name.lowercased()
        switch type {
        case let t where t.contains("bos"): return HDColors.hikeTypeForest
        case let t where t.contains("berg"): return HDColors.hikeTypeMountain
        case let t where t.contains("strand"): return HDColors.hikeTypeBeach
        case let t where t.contains("stad"): return HDColors.hikeTypeCity
        case let t where t.contains("law"): return HDColors.hikeTypePath
        case let t where t.contains("klompen"): return HDColors.hikeTypeMeadow
        case let t where t.contains("hei"): return HDColors.hikeTypeHeather
        case let t where t.contains("duin"): return HDColors.hikeTypeDune
        case let t where t.contains("blokje"): return HDColors.hikeTypeNeighborhood
        case let t where t.contains("dag"): return HDColors.hikeTypeGeneral
        default: return HDColors.mutedGreen
        }
    }
}
