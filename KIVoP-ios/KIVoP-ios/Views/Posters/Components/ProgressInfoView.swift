//
//  ProgressInfoView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 11.12.24.
//

import SwiftUI

struct ProgressInfoView: View {
   let status: Status
   
   func getDateProgressText(status: Status) -> String {
      switch status {
      case .hung:
         return "hängt"
      case .takenDown:
         return "abgehangen"
      case .notDisplayed:
         return "hängt noch nicht"
      case .expiresInOneDay:
         return "hängt"
      case .expired:
         return "hängt"
      }
   }
   
   var value: CGFloat {
      switch status {
      case .hung:
         return 100
      case .takenDown:
         return 140
      case .notDisplayed:
         return 170
      case .expiresInOneDay:
         return 100
      case .expired:
         return 100
      }
   }
   
   var color: Color {
      switch status {
      case .hung:
         return .blue
      case .takenDown:
         return .green
      case .notDisplayed:
         return .gray
      case .expiresInOneDay:
         return .orange
      case .expired:
         return .red
      }
   }
   
    var body: some View {
       Rectangle()
          .fill(color.opacity(0.15))
           .frame(width: value, height: 28)
           .overlay( // border as an overlay
             RoundedRectangle(cornerRadius: 10)
               .stroke(color.opacity(0.15), lineWidth: 1)
                .overlay(Text("Plakat \(getDateProgressText(status: status))")
                  .foregroundStyle(color.mix(with: .black, by: 0.25))
                  .font(.footnote))
                  .fontWeight(.semibold)
           )
           .cornerRadius(10)
    }
}

#Preview {
   ProgressInfoView(status: Status.hung)
}
