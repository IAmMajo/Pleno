import Models

extension User {
    public func toDTO() -> UserDTO {
       .init(
           id: self.id,
           email: self.$email.value,
           name: self.$name.value,
           passwordHash: self.$passwordHash.value,
           role: self.$role.value,
           isActive: self.$isActive.value
       )
   }
}
