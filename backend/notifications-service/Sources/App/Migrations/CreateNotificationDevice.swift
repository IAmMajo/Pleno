import Fluent

struct CreateNotificationDevice: AsyncMigration {
    func prepare(on database: Database) async throws {
        let notificationPlatform = try await database.enum("notification_platform")
            .case("android")
            .case("ios")
            .create()
        try await database.schema("notification_devices")
            .id()
            .field("device_id", .string, .required)
            .field("token", .string, .required)
            .field("platform", notificationPlatform, .required)
            .field(
                "user_id",
                .uuid,
                .required,
                .references("users", "id", onDelete: .cascade)
            )
            .unique(on: "device_id", "platform")
            .unique(on: "token", "platform")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("notification_devices").delete()
        try await database.enum("notification_platform").delete()
    }
}
