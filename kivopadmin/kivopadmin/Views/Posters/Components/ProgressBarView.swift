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

struct ProgressBarView: View {
    let position: PosterPositionResponseDTO
    @State private var isAnimating = false
    
    var value: CGFloat {
        let status = position.status
        switch status {
        case .hangs:
            return 250
        case .takenDown:
            return 500
        case .toHang:
            return 20
        case .overdue:
            return 250
        case .damaged:
            return 250
        default:
            return 250
        }
    }

    var progressBarColor: Color {
        let status = position.status
        switch status {
        case .hangs:
            return .blue
        case .takenDown:
            return .green
        case .toHang:
            return Color(UIColor.secondaryLabel)
        case .overdue:
            return .red
        case .damaged:
            return .orange
        default:
            return Color(UIColor.secondaryLabel)
        }
    }
    
    var body: some View {
        Rectangle()
            .fill(.gray.opacity(0.3)) // Hintergrund der Progress-Bar
            .frame(maxWidth: .infinity, maxHeight: 15)
            .overlay(
                ZStack(alignment: .leading) {
                    // Dynamisch gefärbter Balken
                    RoundedRectangle(cornerRadius: 25)
                        .fill(progressBarColor)
                        .frame(width: value)
                        .cornerRadius(25)
                },
                alignment: .leading // Beide Elemente starten links
            )
            .cornerRadius(25)
            .onAppear {
                isAnimating = true
            }
    }
}
