package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class PosterSummaryResponseDTO (
    var hangs : Int?,
    var toHang : Int?,
    var overdue : Int?,
    var takenDown : Int?,
)
