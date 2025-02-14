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
import JWT
import NotificationsServiceDTOs
import Smtp
import Models
import Vapor
import VaporToOpenAPI

struct NotificationDeviceController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let authMiddleware = AuthMiddleware(payloadType: JWTPayloadDTO.self)
        let notificationDevices = routes.grouped("notification-devices")
        let protectedNotificationDevices = notificationDevices.grouped(authMiddleware)
        protectedNotificationDevices.post(use: register).openAPI(
            summary: "Benachrichtigungsgerät registrieren",
            description:
                "Registriert ein Gerät für den Empfang von Benachrichtigungen.\n\nUnter iOS sollte bei jedem Start " +
                "der App beziehungsweise nach dem Login " +
                "[`UIApplication.registerForRemoteNotifications()`](https://developer.apple.com/documentation/uikit/uiapplication/registerforremotenotifications()) " +
                "aufgerufen werden. Im " +
                "[`didRegisterForRemoteNotifications`](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/application(_:didregisterforremotenotificationswithdevicetoken:))-Handler " +
                "sollte dann **diese Route** mit dem an den Handler übergebenen Token aufgerufen werden. Als " +
                "`deviceID` kann " +
                "[`UIDevice.identifierForVendor`](https://developer.apple.com/documentation/uikit/uidevice/identifierforvendor) " +
                "verwendet werden.\n\nUnter Android muss erst " +
                "[Firebase Cloud Messaging zum Projekt hinzugefügt werden](https://firebase.google.com/docs/android/setup) " +
                "(Firebase-Account ist bereits erstellt). Nach dem Login sollte " +
                "[`FirebaseMessaging.getToken()`](https://firebase.google.com/docs/reference/android/com/google/firebase/messaging/FirebaseMessaging#getToken()) " +
                "aufgerufen und das Token an **diese Route** gesendet werden. Als `deviceId` kann " +
                "[`FirebaseInstallations.getId()`](https://firebase.google.com/docs/reference/android/com/google/firebase/installations/FirebaseInstallations#getId()) " +
                "verwendet werden. Um auf Aktualisierungen des Tokens reagieren zu können, sollte zusätzlich die " +
                "Klasse " +
                "[`FirebaseMessagingService`](https://firebase.google.com/docs/reference/android/com/google/firebase/messaging/FirebaseMessagingService) " +
                "extended und die Methode " +
                "[`onNewToken()`](https://firebase.google.com/docs/reference/android/com/google/firebase/messaging/FirebaseMessagingService#onNewToken(java.lang.String)) " +
                "überschrieben werden. Innerhalb der Methode sollte dann ebenfalls **diese Route** mit dem " +
                "aktualisierten Token aufgerufen werden.",
            body: .type(RegisterNotificationDeviceDTO.self),
            contentType: .application(.json),
            auth: .bearer(description: "JWT Token")
        )
    }
    
    @Sendable
    func register(req: Request) async throws -> HTTPStatus {
        guard let userID = req.jwtPayload?.userID else {
          throw Abort(.unauthorized)
        }
        guard let dto = try? req.content.decode(RegisterNotificationDeviceDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected RegisterNotificationDeviceDTO.")
        }
        let platform = Models.NotificationPlatform(rawValue: dto.platform.rawValue)!

        guard let device = try await NotificationDevice
            .query(on: req.db)
            .filter(\.$platform == platform)
            .filter(\.$deviceID == dto.deviceID)
            .first()
        else {
            try await NotificationDevice(
               deviceID: dto.deviceID,
               token: dto.token,
               platform: platform,
               userID: userID
            ).save(on: req.db)
           return .created
        }
        device.token = dto.token
        device.$user.id = userID
        try await device.update(on: req.db)
        return .created
    }
}
