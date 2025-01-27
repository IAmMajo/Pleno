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
        notification.post(use: send).openAPI(
            summary: "Benachrichtigung senden",
            description: "Sendet eine Benachrichtigung an alle registrierten Geräte eines Users",
            body: .type(SendNotificationDTO.self),
            contentType: .application(.json)
        )
    }
    
    @Sendable
    func send(req: Request) async throws -> HTTPStatus {
        let dto = try req.content.decode(SendNotificationDTO.self)
        guard let user = try await User.find(dto.userID, on: req.db) else {
            throw Abort(.notFound, reason: "User not found")
        }
        if (!user.isNotificationsActive) {
            return .ok
        }
        if (!user.isPushNotificationsActive) {
            try await req.email.sendEmail(
                receiver: user.email,
                subject: dto.subject,
                message: dto.message
            )
            return .ok
        }
        let devices = try await NotificationDevice
            .query(on: req.db)
            .filter(\.$user.$id == dto.userID)
            .all()
        let apnsTopic = Environment.get("APNS_TOPIC") ?? ""
        let ignoreIOS = req.apns.containers.container == nil || apnsTopic.isEmpty
        if (ignoreIOS) {
            req.logger.error(
                "Not sending notification to iOS devices because APNS configuration is missing"
            )
        }
        let ignoreAndroid = req.fcm.configuration == nil
        if (ignoreAndroid) {
            req.logger.error(
                "Not sending notification to Android devices because Firebase Cloud Messaging configuration is missing"
            )
        }
        var pushNotificationSent = false
        for device in devices {
            do {
                if (device.platform == .ios && !ignoreIOS) {
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
                if (
                    apnsError?.reason == .badDeviceToken ||
                    apnsError?.reason == .deviceTokenNotForTopic ||
                    apnsError?.responseStatus == 410
                ) {
                    try await device.delete(on: req.db)
                    continue;
                }
                let googleError = error as? GoogleError
                let googleErrorCode = googleError?.fcmError?.errorCode
                if (googleErrorCode == .invalid || googleErrorCode == .unregistered) {
                    try await device.delete(on: req.db)
                    continue;
                }
                req.logger.error("No notification was sent to a device because an error occured: \(error)")
            }
        }
        if (pushNotificationSent) {
            return .ok
        }
        try await req.email.sendEmail(
            receiver: user.email,
            subject: dto.subject,
            message: dto.message,
            template: "push-notification-failed"
        )
        return .ok
    }
}
