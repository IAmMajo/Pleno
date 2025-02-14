// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Fluent
import Foundation

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
public final class NotificationDevice: Model, @unchecked Sendable {
    public static let schema = "notification_devices"

    @ID(key: .id)
    public var id: UUID?

    @Field(key: "device_id")
    public var deviceID: String
    
    @Field(key: "token")
    public var token: String
    
    @Enum(key: "platform")
    public var platform: NotificationPlatform

    @Parent(key: "user_id")
    public var user: User

    public init() { }

    public init(
        id: UUID? = nil,
        deviceID: String,
        token: String,
        platform: NotificationPlatform,
        userID: UUID
    ) {
        self.id = id
        self.deviceID = deviceID
        self.token = token
        self.platform = platform
        self.$user.id = userID
    }
}

public enum NotificationPlatform: String, Codable, Sendable {
    case android
    case ios
}
