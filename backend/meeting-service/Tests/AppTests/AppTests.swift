@testable import App
import XCTVapor
import Testing
import Fluent

@Suite("App Tests with DB", .serialized)
struct AppTests {
    private func withApp(_ test: (Application) async throws -> ()) async throws {
        let app = try await Application.make(.testing)
        do {
            try await configure(app)
//            try await app.autoMigrate()   
            try await test(app)
//            try await app.autoRevert()   
        }
        catch {
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }
    
    @Test("Test Brew Coffee Route")
    func brewCoffee() async throws {
        try await withApp { app in
            try await app.test(.GET, "brew/coffee", afterResponse: { res async in
                #expect(res.status == .imATeapot)
            })
        }
    }
}
