import Foundation

public struct ReportDamagedPosterPositionDTO: Codable {
    public var image: Data

    public init(image: Data) {
        self.image = image
    }
}
