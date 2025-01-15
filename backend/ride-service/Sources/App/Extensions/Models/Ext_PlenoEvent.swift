import Models
import RideServiceDTOs

extension PlenoEvent {
    
    public func patchWithDTO(dto: PatchEventDTO) {
        if let name = dto.name {
            self.name = name
        }
        
        if let description = dto.description {
            self.description = description
        }
        
        if let starts = dto.starts {
            self.starts = starts
        }
        
        if let ends = dto.ends {
            self.ends = ends
        }
        
        if let latitude = dto.latitude {
            self.latitude = latitude
        }
        
        if let longitude = dto.longitude {
            self.longitude = longitude
        }
    }
}
