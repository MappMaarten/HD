import Foundation
import SwiftData

@Model
final class UserData {
    var name: String = ""
    var email: String = ""
    var isCloudSyncEnabled: Bool = false
    var updatedAt: Date = Date()

    init(
        name: String = "",
        email: String = "",
        isCloudSyncEnabled: Bool = false
    ) {
        self.name = name
        self.email = email
        self.isCloudSyncEnabled = isCloudSyncEnabled
        self.updatedAt = Date()
    }
}
