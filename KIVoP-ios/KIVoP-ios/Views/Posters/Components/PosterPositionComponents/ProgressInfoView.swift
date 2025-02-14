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

//
//  ProgressInfoView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 11.12.24.
//

import SwiftUI
import PosterServiceDTOs

// A SwiftUI view that visually represents the status of a position
// It displays a colored rectangle with different statuses and text labels
struct ProgressInfoView: View {
   @Environment(\.colorScheme) var colorScheme
   let position: PosterPositionResponseDTO
   
   // Determines the text, color, and size for the status of a position
   func getInfo() -> (text: String, value: CGFloat, color: Color) {
      let status = position.status
      switch status {
      case .hangs:
         // Checks if the position expires within the next 24 hours
         if position.expiresAt < Calendar.current.date(byAdding: .day, value: 1, to: Date())! {
            return (text: NSLocalizedString("hängt", comment: ""), value: 100, color: .orange)
         } else {
            return (text: NSLocalizedString("hängt", comment: ""), value: 100, color: .blue)
         }
      case .takenDown:
         return (text: NSLocalizedString("abgehängt", comment: ""), value: 140, color: .green)
      case .toHang:
         return (text: NSLocalizedString("hängt noch nicht", comment: ""), value: 170, color: .gray)
      case .overdue:
         return (text: NSLocalizedString("hängt (überfällig)", comment: ""), value: 175, color: .red)
      case .damaged:
         return (text: NSLocalizedString("ist beschädigt oder fehlt", comment: ""), value: 210, color: .yellow)
      }
   }
   
    var body: some View {
       Rectangle()
          .fill(getInfo().color.opacity(0.15))
          .frame(width: getInfo().value, height: 28)
           .overlay(
            // Draws a border using an overlay
             RoundedRectangle(cornerRadius: 10)
               .stroke(getInfo().color.opacity(0.15), lineWidth: 1)
               .overlay(Text("Plakat \(getInfo().text)") // Displays the text label inside the rectangle
                  .foregroundStyle(getInfo().color.mix(with: colorScheme == .dark ? .white : .black, by: 0.25))
                  .font(.footnote))
                  .fontWeight(.semibold)
           )
           .cornerRadius(10)
    }
}

#Preview {
}
