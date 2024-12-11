import Models

extension Ride {
    public func toGetRideOverviewDTO() throws -> GetRideOverviewDTO {
        return .init(id: self.id, name: self.name, description: self.description, starts: self.starts)
    }
    
    public func patchWithDTO(dto: PatchRideDTO) {
        if let name = dto.name {
            self.name = name
        }
        
        if let description = dto.description {
            self.description = description
        }
        
        if let starts = dto.starts {
            self.starts = starts
        }
        
        if let latitude = dto.latitude {
            self.latitude = latitude
        }
        
        if let longitude = dto.longitude {
            self.longitude = longitude
        }
    }
}
