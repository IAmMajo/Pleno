//TODO: REMOVE WHEN DTOS ARRIVE
package net.ipv64.kivop.models

import java.time.LocalDateTime
import java.util.UUID

data class GetSpecialRideDTO (
  val id: UUID,
  val name: String,
  val starts: LocalDateTime,
  val ends: LocalDateTime,
  val emptySeats: Int,
  val allocatedSeats: Int,
  val isSelfDriver: Boolean,
  val isSelfAccepted: Boolean,
)

data class GetSpecialRideDetailDTO  (
  val id: UUID,
  val name: String,
  val starts: LocalDateTime,
  val ends: LocalDateTime,
  val emptySeats: Int,
  val destinationLongitude: Double,
  val destinationLatitude: Double,
  val startLongitude: Double,
  val startLatitude: Double,
  val driverName: String,
  val isSelfDriver: Boolean,
  val description: String,
  val riders: List<String>?
)
//TODO: REMOVE WHEN DTOS ARRIVE