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
   
    var body: some View {
       Rectangle()
           .fill(.gray.opacity(0.3))
           .frame(maxWidth: .infinity, maxHeight: 15)
           .overlay(
            HStack {
               RoundedRectangle(cornerRadius: 25)
                  .fill(.blue)
                  .frame(width: value)
               Spacer()
            }
           )
           .cornerRadius(25)
    }
}

#Preview {
//   ProgressBarView(status: Status.hung)
}
