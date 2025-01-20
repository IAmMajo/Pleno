//
//  ProgressInfoView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 11.12.24.
//

import SwiftUI
import PosterServiceDTOs

struct ProgressInfoView: View {
   let position: PosterPositionResponseDTO
   
   func getDateProgressText(position: PosterPositionResponseDTO) -> String {
      let status = position.status
      switch status {
      case "hangs":
         return "hängt"
      case "takenDown":
         return "abgehangen"
      case "toHang":
         return "hängt noch nicht"
      case "overdue":
         return "hängt"
      default:
         return ""
      }
   }
   
   var value: CGFloat {
      let status = position.status
      switch status {
      case "hangs":
         return 100
      case "takenDown":
         return 140
      case "toHang":
         return 170
      case "overdue":
         return 100
      default:
         return 100
      }
   }
   
   var color: Color {
      let status = position.status
      switch status {
      case "hangs":
         if position.expiresAt < Calendar.current.date(byAdding: .day, value: 1, to: Date())! {
            return .orange
         } else {
            return .blue
         }
      case "takenDown":
         return .green
      case "toHang":
         return .gray
      case "overdue":
         return .red
      default:
         return .gray
      }
   }
   
    var body: some View {
       Rectangle()
          .fill(color.opacity(0.15))
           .frame(width: value, height: 28)
           .overlay( // border as an overlay
             RoundedRectangle(cornerRadius: 10)
               .stroke(color.opacity(0.15), lineWidth: 1)
                .overlay(Text("Plakat \(getDateProgressText(position: position))")
                  .foregroundStyle(color.mix(with: .black, by: 0.25))
                  .font(.footnote))
                  .fontWeight(.semibold)
           )
           .cornerRadius(10)
    }
}

#Preview {
//   ProgressInfoView(status: Status.hung)
}
