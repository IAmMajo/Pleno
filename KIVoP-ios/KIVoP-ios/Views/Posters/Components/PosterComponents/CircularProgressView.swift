// This file is licensed under the MIT-0 License.
//
//  CircularProgressView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 11.12.24.
//

import SwiftUI
import PosterServiceDTOs

// A circular progress indicator that visually represents a progress value
struct CircularProgressView: View {
   let value: Int // The current value representing progress
   let total: Int // The total value representing the maximum progress
   let status: PosterPositionStatus // The status of the poster position (used for determining the color)
   
   // Calculates the progress as a fraction (between 0.0 and 1.0)
   var progress: Double {
      return Double(value) / Double(total)
   }
   
   // Determines the color of the progress indicator based on status
   var getColor: Color {
      return status == .hangs ? .blue : .green
   }
   
   var body: some View {
      ZStack {
         // Background Circle (Gray) - Represents total progress
         Circle()
            .stroke(
               .gray.opacity(0.3),
               lineWidth: 7
            )
         // Foreground Circle (Progress Indicator) - Represents current progress
         Circle()
            .trim(from: 0, to: progress) // Trims the circle to show progress
            .stroke(
               getColor,
               style: StrokeStyle(
                  lineWidth: 7,
                  lineCap: .round
               )
            )
            .rotationEffect(.degrees(-90)) // Rotates to start from the top
            .overlay (
            // Progress Label (Shows `value/total` inside the circle)
            Text("\(value)/\(total)")
               .font(.system(size: 18))
               .fontWeight(.semibold)
               .foregroundStyle(Color(UIColor.label).opacity(0.6).mix(with: getColor, by: 0.6))
            )
      }
   }
}

#Preview {
   CircularProgressView(value: 2, total: 3, status: .hangs)
      .frame(maxWidth: 45, maxHeight: 45)
}
