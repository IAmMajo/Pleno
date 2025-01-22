import APNS
import Fluent
import Models
import NotificationsServiceDTOs
import Smtp
import Vapor
import VaporAPNS
import VaporToOpenAPI

struct NotificationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let notification = routes.grouped("internal", "notification")
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
                }
            } catch {
                req.logger.notice("Sending notification to a device failed, deleting device: \(error)")
                try await device.delete(on: req.db)
            }
        }
        do {
            try await req.email.sendEmail(
                receiver: user.email,
                subject: dto.subject,
                message: dto.message
            )
        } catch {
            req.logger.error("No email was sent because an error occurred: \(error)")
        }
        return .ok
    }
}
