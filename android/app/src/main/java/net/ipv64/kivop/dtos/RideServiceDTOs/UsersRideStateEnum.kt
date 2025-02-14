package net.ipv64.kivop.dtos.RideServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

enum class UsersRideState {
    nothing,
    requested,
    accepted,
    driver,
}
