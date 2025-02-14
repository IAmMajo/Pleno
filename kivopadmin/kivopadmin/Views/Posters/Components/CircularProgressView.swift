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

