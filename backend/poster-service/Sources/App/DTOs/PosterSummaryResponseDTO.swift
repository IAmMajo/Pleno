public struct PosterSummaryResponseDTO: Codable {
    public var hangs: Int
    public var toHang: Int
    public var overdue: Int
    public var takenDown: Int
    
    public init(
        hangs: Int? = 0, toHang: Int? = 0, overdue: Int? = 0, takenDown: Int? = 0
    ) {
        self.hangs = hangs!
        self.toHang = toHang!
        self.overdue = overdue!
        self.takenDown = takenDown!
    }
}
