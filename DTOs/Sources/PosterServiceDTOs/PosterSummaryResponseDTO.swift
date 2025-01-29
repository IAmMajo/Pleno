import Foundation

public struct PosterSummaryResponseDTO: Codable {
    public var hangs: Int
    public var toHang: Int
    public var overdue: Int
    public var takenDown: Int
    public var damaged: Int
    public var nextTakeDown: Date?
    
    public init (hangs: Int = 0, toHang: Int = 0, overdue: Int = 0, takenDown: Int = 0, damaged: Int = 0, nextTakeDown: Date? = nil){
        self.hangs = hangs
        self.toHang = toHang
        self.overdue = overdue
        self.takenDown = takenDown
        self.damaged = damaged
        self.nextTakeDown = nextTakeDown
    }
}
