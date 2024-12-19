//
//  PagedResponseDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 06.12.24.
//

public struct PagedResponseDTO<Item: Codable>: Codable {
   public var items: [Item]
    public var metadata: CustomPageMetadata?
    
    public init(items:[Item],metadata:CustomPageMetadata?){
        self.items = items
        self.metadata = metadata
    }
}

public struct CustomPageMetadata: Codable {
    public let currentPage: Int
    public let perPage: Int
    public let totalItems: Int
    public let totalPages: Int
}
