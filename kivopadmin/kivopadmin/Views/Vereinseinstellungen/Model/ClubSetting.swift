import Foundation

struct ClubSetting: Identifiable, Codable {
    var id: String
    var key: String
    var description: String?
    var value: String
    var datatype: String
}
