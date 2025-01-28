//
//  ProgressInfoView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 11.12.24.
//

import SwiftUI
import PosterServiceDTOs

struct ProgressInfoView: View {
   @Environment(\.colorScheme) var colorScheme
   let position: PosterPositionResponseDTO
   
   func getInfo() -> (text: String, value: CGFloat, color: Color) {
      let status = position.status
      switch status {
      case .hangs:
         if position.expiresAt < Calendar.current.date(byAdding: .day, value: 1, to: Date())! {
            return (text: "hängt", value: 100, color: .orange)
         } else {
            return (text: "hängt", value: 100, color: .blue)
         }
      case .takenDown:
         return (text: "abgehängt", value: 140, color: .green)
      case .toHang:
         return (text: "hängt noch nicht", value: 170, color: .gray)
      case .overdue:
         return (text: "hängt (überfällig)", value: 175, color: .red)
      case .damaged:
         return (text: "ist beschädigt, oder fehlt", value: 230, color: .yellow)
      }
   }
   
    var body: some View {
       Rectangle()
          .fill(getInfo().color.opacity(0.15))
          .frame(width: getInfo().value, height: 28)
           .overlay( // border as an overlay
             RoundedRectangle(cornerRadius: 10)
               .stroke(getInfo().color.opacity(0.15), lineWidth: 1)
               .overlay(Text("Plakat \(getInfo().text)")
                  .foregroundStyle(getInfo().color.mix(with: colorScheme == .dark ? .white : .black, by: 0.25))
                  .font(.footnote))
                  .fontWeight(.semibold)
           )
           .cornerRadius(10)
    }
}

#Preview {
//   ProgressInfoView(status: Status.hung)
}
