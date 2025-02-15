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

import APNS
import APNSCore
import FCM
import Fluent
import Models
import NotificationsServiceDTOs
import Smtp
import Vapor
import VaporAPNS
import VaporToOpenAPI

struct NotificationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let notification = routes.grouped("internal", "notification").groupedOpenAPI(
            tags: .init(name: "Intern", description: "Nur intern erreichbar.")
        )
        notification.put(use: send).openAPI(
            summary: "Benachrichtigung senden",
            description: "Sendet eine Benachrichtigung an alle registrierten Geräte eines Users",
            body: .type(SendNotificationDTO.self),
            contentType: .application(.json)
        )
    }
    
    @Sendable
    func send(req: Request) async throws -> HTTPStatus {
        guard let dto = try? req.content.decode(SendNotificationDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected SendNotificationDTO.")
        }
        guard let user = try await User.find(dto.userID, on: req.db) else {
            throw Abort(.notFound)
        }
        guard user.isNotificationsActive else {
            return .noContent
        }
        guard user.isPushNotificationsActive else {
            try await req.email.sendEmail(
                receiver: user.email,
                subject: dto.subject,
                message: dto.message
            )
            return .noContent
        }
        let devices = try await NotificationDevice
            .query(on: req.db)
            .filter(\.$user.$id == dto.userID)
            .all()
        let apnsTopic = Environment.get("APNS_TOPIC") ?? ""
        let ignoreIOS = req.apns.containers.container == nil || apnsTopic.isEmpty
        if ignoreIOS {
            req.logger.error(
                "Not sending notification to iOS devices because APNS configuration is missing"
            )
        }
        let ignoreAndroid = req.fcm.configuration == nil
        if ignoreAndroid {
            req.logger.error(
                "Not sending notification to Android devices because Firebase Cloud Messaging configuration is missing"
            )
        }
        var pushNotificationSent = false
        for device in devices {
            do {
                if device.platform == .ios && !ignoreIOS {
                    try await req.apns.client.sendAlertNotification(
                        .init(
                            alert: .init(
                                subtitle: .raw(dto.subject),
                                body: .raw(dto.message)
                            ),
                            expiration: .none,
                            priority: .immediately,
                            topic: apnsTopic,
                            payload: APNSPayloadDTO(payload: dto.payload ?? ""),
                            sound: .default
                        ),
                        deviceToken: device.token
                    )
                    pushNotificationSent = true
                } else if device.platform == .android && !ignoreAndroid {
                    let _ = try await req.fcm.send(
                        .init(
                            token: device.token,
                            notification: .init(
                                title: dto.subject,
                                body: dto.message
                            ),
                            data: ["payload": dto.payload ?? ""],
                            android: .init(
                                notification: .init(sound: "default")
                            )
                        ),
                        on: req.eventLoop
                    ).get()
                    pushNotificationSent = true
                }
            } catch {
                let apnsError = error as? APNSError
                guard
                    apnsError?.reason != .badDeviceToken,
                    apnsError?.reason != .deviceTokenNotForTopic,
                    apnsError?.responseStatus != 410
                else {
                    try await device.delete(on: req.db)
                    continue;
                }
                let googleError = error as? GoogleError
                let googleErrorCode = googleError?.fcmError?.errorCode
                guard googleErrorCode != .invalid, googleErrorCode != .unregistered else {
                    try await device.delete(on: req.db)
                    continue;
                }
                req.logger.error("No notification was sent to a device because an error occured: \(error)")
            }
        }
        guard !pushNotificationSent else {
            return .noContent
        }
        try await req.email.sendEmail(
            receiver: user.email,
            subject: dto.subject,
            message: dto.message,
            template: "push-notification-failed"
        )
        return .noContent
    }
}
