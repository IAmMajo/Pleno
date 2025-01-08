import Models
import RideServiceDTOs

extension SpecialRide {
//    public func toGetSpecialRideDetailDTO() -> GetSpecialRideDetailDTO {
//        return .init(id: self.id, name: self.name, description: self.description, starts: self.starts, latitude: self.latitude, longitude: self.longitude)
//    }
    
    public func patchWithDTO(dto: PatchSpecialRideDTO) {
        if let name = dto.name {
            self.name = name
        }
        
        if let description = dto.description {
            self.description = description
        }
        
        if let vehicleDescription = dto.vehicleDescription {
            self.vehicleDescription = vehicleDescription
        }
        
        if let starts = dto.starts {
            self.starts = starts
        }
        
        if let ends = dto.ends {
            self.ends = ends
        }
        
        if let startLatitude = dto.startLatitude {
            self.startLatitude = startLatitude
        }
        
        if let startLongitude = dto.startLongitude {
            self.startLongitude = startLongitude
        }
        
        if let destinationLatitude = dto.destinationLatitude {
            self.destinationLatitude = destinationLatitude
        }
        
        if let destinationLongitude = dto.destinationLongitude {
            self.destinationLongitude = destinationLongitude
        }
        
        if let emptySeats = dto.emptySeats {
            self.emptySeats = emptySeats
        }
    }
}
