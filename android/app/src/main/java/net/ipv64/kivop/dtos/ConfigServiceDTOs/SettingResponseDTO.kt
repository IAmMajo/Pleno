package net.ipv64.kivop.dtos.ConfigServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

public struct SettingResponseDTO: Codable{
    var id : UUID?,
    var key : String,
    var datatype : String,
    var value : String,
    var description : String?,
}
