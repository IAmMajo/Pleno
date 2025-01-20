//
//  ProgressBarView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 11.12.24.
//

import SwiftUI

struct ProgressBarView: View {
   let status: String
   
   var value: CGFloat {
      switch status {
      case "hung":
         return 190
      case "takenDown":
         return 500
      case "notDisplayed":
         return 20
      case "expiresInOneDay":
         return 190
      case "expired":
         return 190
      default:
          return 0
      }
   }
   
    var body: some View {
       Rectangle()
           .fill(.gray.opacity(0.3))
           .frame(width: .infinity, height: 15)
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

//#Preview {
//   ProgressBarView(status: Status.hung)
//}
