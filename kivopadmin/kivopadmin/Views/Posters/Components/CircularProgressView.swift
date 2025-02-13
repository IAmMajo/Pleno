// This file is licensed under the MIT-0 License.

import SwiftUI
import PosterServiceDTOs

// Gibt an, wie viele Plakate aufgehangen oder noch abzuhängen sind
struct CircularProgressView: View {
    let poster: PosterWithSummary
    let status: PosterPositionStatus
    
    // Berechnung, wie viel Prozent abgeschlossen sind
    var progress: Double {
        let hangs = Double(poster.summary?.hangs ?? 0)
        let overdue = Double(poster.summary?.overdue ?? 0)
        let damaged = Double(poster.summary?.damaged ?? 0)
        let toHang = Double(poster.summary?.toHang ?? 0)
        let takenDown = Double(poster.summary?.takenDown ?? 0)

        let totalHangs = hangs + overdue + damaged
        let totalTasks = totalHangs + toHang

        if status == .hangs {
            let denominator = totalTasks + takenDown
            return denominator == 0 ? 0 : (totalHangs + takenDown) / denominator
        } else {
            let denominator = totalTasks + takenDown
            return denominator == 0 ? 0 : takenDown / denominator
        }

    }

    
    // Farbe des Kreises und der Schrift in Abhängigkeit des Status
    var getColor: Color {
        return status == .hangs ? .blue : .green
    }
    
    var body: some View {
        // Summary auslesen
        let hangs = poster.summary?.hangs ?? 0
        let overdue = poster.summary?.overdue ?? 0
        let damaged = poster.summary?.damaged ?? 0
        let toHang = poster.summary?.toHang ?? 0
        let takenDown = poster.summary?.takenDown ?? 0

        let totalHangs = hangs + overdue + damaged
        let totalTasks = totalHangs + toHang

        let overlayText = status == .hangs
            ? "\(totalHangs + takenDown)/\(totalTasks + takenDown)"
            : "\(takenDown)/\(totalTasks + takenDown)"
        
        
        HStack{
            if status == .hangs {
                Text("Aufgehangen")
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }
            if status != .hangs {
                Text("Abgehangen")
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }
            ZStack {
                Circle()
                    .stroke(
                        .gray.opacity(0.3),
                        lineWidth: 4
                    )
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        getColor,
                        style: StrokeStyle(
                            lineWidth: 4,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .overlay(
                        Text(overlayText)
                            .font(.system(size: 10))
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(UIColor.label).opacity(0.6).mix(with: getColor, by: 0.6))
                    )

            }
            .frame(maxWidth: 25, maxHeight: 35)
            .padding(.bottom, 5)
        }


    }
}

