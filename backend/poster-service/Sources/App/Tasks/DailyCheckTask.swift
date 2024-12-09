//
//  DailyCheckTask.swift
//  poster-service
//
//  Created by Dennis Sept on 05.12.24.
//

import Vapor
import Models
import Fluent

struct DailyCheckTask: LifecycleHandler {
    func didBoot(_ app: Application) throws {
        // Startet eine asynchrone Task nach dem Booten der App
        Task {
            while !Task.isCancelled {
                // Einmal täglich ausführen (z. B. alle 24 Stunden)
                try? await Task.sleep(for: .seconds(86400))
                await performDailyCheck(app)
            }
        }
    }
    
    /// Führt die tägliche Prüfung aus und sendet ggf. Emails
    private func performDailyCheck(_ app: Application) async {
        
        let posterReminder: Int? = await SettingsManager.shared.getSetting(forKey: "poster_reminder_interval")
        
        let now = Date()
        let thresholdDate = now.addingTimeInterval(TimeInterval(posterReminder ?? 3))
        
        do {
            
            let positions = try await PosterPosition.query(on: app.db)
                .filter(\.$is_Displayed == true)
                .filter(\.$expires_at <= thresholdDate)
                .with(\.$responsibleUser)
                .all()
            
            for position in positions {
                let email = position.responsibleUser.email
                let dto = SendEmailDTO(
                    receiver: email,
                    //receiver: "dennis.sept@hsrw.org",
                    subject: "Erinnerung: Poster muss abgehangen werden",
                    message: "Das Poster (ID: \(position.id?.uuidString ?? "Unbekannt")) muss abgehangen werden."
                )
                
                let response = try await app.client.post("http://kivop-notification-service/email") { request in
                    try request.content.encode(dto, as: .json)
                }
                
                if (200...299).contains(response.status.code) {
                    app.logger.info("Email-Benachrichtigung an \(email) erfolgreich gesendet.")
                } else {
                    app.logger.error("Fehler beim Senden der Email-Benachrichtigung an \(email): \(response.status)")
                }
            }
            
        } catch {
            app.logger.error("Fehler bei der täglichen Prüfung: \(error.localizedDescription)")
        }
    }
    
}
