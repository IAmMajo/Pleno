package net.ipv64.kivop.dtos.ConfigServiceDTOs

import java.util.UUID

data class BulkUpdateResponseDTO(var updated: List<UUID>, var failed: Map<UUID, String>)
