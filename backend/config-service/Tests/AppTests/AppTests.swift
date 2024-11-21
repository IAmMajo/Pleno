@testable import App
import XCTVapor
import Testing
import Fluent
import Models

@Suite("App Tests with DB", .serialized)
struct AppTests {
    private func withApp(_ test: (Application) async throws -> ()) async throws {
        let app = try await Application.make(.testing)
        do {
            try await configure(app)
            try await app.autoMigrate()
            try await test(app)
            try await app.autoRevert()
        }
        catch {
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }
    

    @Test("Test GET /config - Get All Settings")
    func testGetAllSettings() async throws {
        try await withApp { app in
            // Seed some test settings
            try await Setting(key: "test1", datatype: .string, value: "value1", description: "desc1")
                .save(on: app.db)
            try await Setting(key: "test2", datatype: .integer, value: "42", description: "desc2")
                .save(on: app.db)

            try await app.test(.GET, "/config", afterResponse: { res async in
                #expect(res.status == .ok)
                #expect(res.body.string.contains("\"key\":\"test1\""))
                #expect(res.body.string.contains("\"key\":\"test2\""))
            })
        }
    }

    @Test("Test GET /config/:id - Get Setting by ID")
    func testGetSettingByID() async throws {
        try await withApp { app in
            // Create a test setting
            let setting = Setting(key: "testKey", datatype: .string, value: "testValue")
            try await setting.save(on: app.db)

            try await app.test(.GET, "/config/\(setting.requireID())", afterResponse: { res async in
                #expect(res.status == .ok)
                #expect(res.body.string.contains("\"key\":\"testKey\""))
            })
        }
    }

    @Test("Test PATCH /config/:id - Update Setting by ID")
    func testUpdateSettingByID() async throws {
        try await withApp { app in
            // Create a test setting
            let setting = Setting(key: "updatable", datatype: .string, value: "oldValue")
            try await setting.save(on: app.db)

            let updatePayload = """
            {
                "value": "newValue"
            }
            """

            try await app.test(.PATCH, "/config/\(setting.requireID())", headers: ["Content-Type": "application/json"], body: .init(string: updatePayload), afterResponse: { res async in
                #expect(res.status == .ok)
                #expect(res.body.string.contains("\"value\":\"newValue\""))
            })

            // Verify the update in the database
            let updatedSetting = try await Setting.find(setting.requireID(), on: app.db)
            #expect(updatedSetting?.value == "newValue")
        }
    }

    @Test("Test PATCH /config - Bulk Update")
    func testBulkUpdate() async throws {
        try await withApp { app in
            // Create test settings
            let setting1 = Setting(key: "bulk1", datatype: .string, value: "value1")
            let setting2 = Setting(key: "bulk2", datatype: .integer, value: "123")
            try await setting1.save(on: app.db)
            try await setting2.save(on: app.db)

            // Define payload structure
            struct UpdatePayload: Encodable {
                let id: String
                let value: String
            }

            struct BulkUpdatePayload: Encodable {
                let updates: [UpdatePayload]
            }

            // Create bulk update payload
            let bulkUpdatePayload = BulkUpdatePayload(updates: [
                UpdatePayload(id: try setting1.requireID().uuidString, value: "newValue1"),
                UpdatePayload(id: try setting2.requireID().uuidString, value: "456")
            ])

            // Encode payload
            let payloadData = try JSONEncoder().encode(bulkUpdatePayload)

            // Test bulk update
            try await app.test(
                .PATCH,
                "/config",
                headers: ["Content-Type": "application/json"],
                body: .init(data: payloadData)
            ) { res async in
                #expect(res.status == .multiStatus)
                #expect(res.body.string.contains("\(setting1.requireID())"))
                #expect(res.body.string.contains("\(setting2.requireID())"))
            }

            // Verify updates in the database
            let updatedSetting1 = try await Setting.find(setting1.requireID(), on: app.db)
            let updatedSetting2 = try await Setting.find(setting2.requireID(), on: app.db)
            #expect(updatedSetting1?.value == "newValue1")
            #expect(updatedSetting2?.value == "456")
        }
    }

}
