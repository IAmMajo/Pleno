import Vapor
import Fluent
import Models


struct DailyCheckTask: LifecycleHandler {
    func didBoot(_ app: Application) throws {
        app.logger.info("Starting DailyCheckTask")
        scheduleDailyCheck(app: app)
    }
    
    private func scheduleDailyCheck(app: Application) {
        Task.detached {
            while !Task.isCancelled {
                let now = Date()
                let calendar = Calendar.current
                var nextRunDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
                nextRunDateComponents.hour = 5
                nextRunDateComponents.minute = 0
                nextRunDateComponents.second = 0
                
                guard let nextRunDate = calendar.date(from: nextRunDateComponents) else {
                    app.logger.error("Failed to compute next run date for DailyCheckTask")
                    // Retry after 1 hour
                    try? await Task.sleep(nanoseconds: 3600 * 1_000_000_000)
                    continue
                }
                
                var delay: TimeInterval = nextRunDate.timeIntervalSince(now)
                if delay < 0 {
                    // Wenn die Zeit heute bereits vorbei ist, plane für morgen
                    delay += 24 * 60 * 60
                }
                
                app.logger.info("DailyCheckTask will run in \(delay) seconds")
                
                do {
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                } catch {
                    app.logger.error("DailyCheckTask sleep interrupted: \(error)")
                    break
                }
                
                await performDailyCheck(app)
            }
        }
    }
    
    /// Führt die tägliche Prüfung aus und sendet ggf. Emails
    private func performDailyCheck(_ app: Application) async {
        // Abrufen des poster_reminder_interval-Werts (in Tagen)
        let posterReminder: Int? = await SettingsManager.shared.getSetting(forKey: "poster_reminder_interval")
        
        // Verwenden von einen Standardwert von 3 Tagen, falls poster_reminder nicht gesetzt ist
        let reminderDays = posterReminder ?? 0
        
        let now = Date()
        let calendar = Calendar.current
        
        // Berechnen des targetDate: targetDate = now + reminderDays
        guard let targetDate = calendar.date(byAdding: .day, value: reminderDays, to: now) else {
            app.logger.error("Fehler beim Berechnen des targetDate für DailyCheckTask.")
            return
        }
        
        app.logger.info("Gefundene PosterPositionen für Erinnerungen: \(targetDate)")
        do {
            // Abfrage der PosterPositions, deren expires_at genau dem targetDate entspricht
            let positions = try await PosterPosition.query(on: app.db)
                .filter(\.$posted_by.$id != nil)
                .filter(\.$removed_by.$id == nil)
                .filter(\.$expires_at <= targetDate)
                .with(\.$posted_by)
                .with(\.$responsibilities)
                .all()
            
            app.logger.info("Gefundene PosterPositionen für Erinnerungen: \(positions.count)")
            
            for position in positions {
                for responsible in position.responsibilities {
                    let email = responsible.user.email
                    
                    // Berechnen der Tage bis zum Ablaufdatum
                    let daysLeft: Int?
                    if reminderDays < 0 {
                        daysLeft = calendar.dateComponents([.day], from: now, to: position.expires_at).day
                    } else {
                        daysLeft = nil
                    }
                    
                    // Erstellen der Nachricht basierend auf daysLeft
                    let message: String
                    if let days = daysLeft, days >= 0 {
                        message = "Das Poster (ID: \(position.id?.uuidString ?? "Unbekannt")) muss abgehangen werden. Noch \(days) Tag(e) bis zum Ablaufdatum."
                    } else {
                        message = "Das Poster (ID: \(position.id?.uuidString ?? "Unbekannt")) muss abgehangen werden."
                    }
                    
                    let dto = SendEmailDTO(
                        receiver: email,
                        subject: "Erinnerung: Poster muss abgehangen werden",
                        message: message
                    )
                    
                    do {
                        let jsonData = try JSONEncoder().encode(dto)
                        // Setzen der Content-Type-Header und Body manuell
                        var headers = HTTPHeaders()
                        headers.add(name: .contentType, value: "application/json")
                        
                        let response = try await app.client.post("https://kivop.ipv64.net/email") { request in
                            request.headers = headers
                            request.body = .init(data: jsonData)
                        }
                        
                        if (200...299).contains(response.status.code) {
                            app.logger.info("Email-Benachrichtigung an \(email) erfolgreich gesendet.")
                        } else {
                            app.logger.error("Fehler beim Senden der Email-Benachrichtigung an \(email): \(response.status)")
                        }
                    } catch {
                        app.logger.error("Fehler beim Senden der Email an \(email): \(error.localizedDescription)")
                    }
                }
            }
            
        } catch {
            app.logger.error("Fehler bei der täglichen Prüfung: \(error.localizedDescription)")
        }
    }
}
