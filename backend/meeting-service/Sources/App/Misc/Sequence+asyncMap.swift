extension Sequence {
    /// Asynchronously returns an array containing the results of mapping the given closure over the sequence's elements.
    func map<T>(_ transform: (Element) async throws -> T) async rethrows -> [T] {
        var values = [T]()
        for element in self {
            try await values.append(transform(element))
        }
        return values
    }
}
