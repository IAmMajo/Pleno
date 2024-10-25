import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    try app.register(collection: TodoController())
    try app.register(collection: MeetingController())
    try app.register(collection: AttendanceController())
    try app.register(collection: VotingController())
    try app.register(collection: RecordController())
}
