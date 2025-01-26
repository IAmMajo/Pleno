//
//  ProgressBarView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 11.12.24.
//

import SwiftUI
import PosterServiceDTOs

struct ProgressBarView: View {
    let position: PosterPositionResponseDTO
    @State private var isAnimating = false
    
    var value: CGFloat {
        let status = position.status
        switch status {
        case "hangs":
            return 190
        case "takenDown":
            return 500
        case "toHang":
            return 20
        case "overdue":
            return 190
        default:
            return 190
        }
    }
    
    var progressBarColor: Color {
        let status = position.status
        switch status {
        case "hangs":
            return .blue
        case "takenDown":
            return .green
        case "toHang":
            return Color(UIColor.secondaryLabel)
        case "overdue":
            return .red
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

#Preview {
//   ProgressBarView(status: Status.hung)
}
