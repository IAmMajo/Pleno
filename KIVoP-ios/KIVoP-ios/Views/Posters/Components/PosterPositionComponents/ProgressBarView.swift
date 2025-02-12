// This file is licensed under the MIT-0 License.
//
//  ProgressBarView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 11.12.24.
//

import SwiftUI
import PosterServiceDTOs

// A progress bar view that visually represents the status of a position
struct ProgressBarView: View {
   let position: PosterPositionResponseDTO
   
   /// Determines the progress bar width based on the position's status
   var value: CGFloat {
      let status = position.status
      switch status {
      case .hangs:
         return 190
      case .takenDown:
         return 500
      case .toHang:
         return 20
      case .overdue:
         return 190
      default:
         return 190
      }
   }
   
    var body: some View {
       // ProgressBar background in gray
       Rectangle()
           .fill(.gray.opacity(0.3))
           .frame(maxWidth: .infinity, maxHeight: 15)
           .overlay(
            HStack {
               // displays progress in blue
               RoundedRectangle(cornerRadius: 25)
                  .fill(.blue)
                  .frame(width: value) // Dynamic width based on `value`
               Spacer()
            }
           )
           .cornerRadius(25)
    }
}

#Preview {
}
