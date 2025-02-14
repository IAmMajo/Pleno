// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
