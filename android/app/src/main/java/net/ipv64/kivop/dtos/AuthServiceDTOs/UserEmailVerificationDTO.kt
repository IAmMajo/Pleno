package net.ipv64.kivop.dtos.AuthServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class UserEmailVerificationDTO (
    var uid : UUID?,
    var name : String?,
    var isActive : Boolean?,
    var emailStatus : VerificationStatus?,
    var createdAt : LocalDateTime?,
    // Benutzerdefinierte Dekodierung
     else {
            self.uid = nil
        )
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive)
        self.emailStatus = try container.decodeIfPresent(VerificationStatus.self, forKey: .emailStatus)
        self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
    }
    private enum CodingKeys: String, CodingKey {
        uid,
        name,
        isActive,
        emailStatus,
        createdAt,
    }
}
enum class VerificationStatus {
    failed,
    pending,
    verified,
}
