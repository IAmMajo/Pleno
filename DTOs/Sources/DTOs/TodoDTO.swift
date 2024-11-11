import Foundation

public struct TodoDTO: Codable {
    public var id: UUID?
    public var title: String?
    
    public init() {}
    
    public init(id: UUID? = nil, title: String) {
        self.id = id
        self.title = title
    }
}
