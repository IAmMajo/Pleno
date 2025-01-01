//
//  CircularProgressView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 11.12.24.
//

import SwiftUI

struct CircularProgressView: View {
    
   let value: Int
   let total: Int
   let status: Status
   
   var progress: Double {
      return Double(value) / Double(total)
   }
   
   var getColor: Color {
      return status == .hung ? .blue : .green
   }
   
   var body: some View {
      ZStack {
         Circle()
            .stroke(
               .gray.opacity(0.3),
               lineWidth: 7
            )
         Circle()
            .trim(from: 0, to: progress)
            .stroke(
               getColor,
               style: StrokeStyle(
                  lineWidth: 7,
                  lineCap: .round
               )
            )
            .rotationEffect(.degrees(-90))
      }
   }
}

#Preview {
   CircularProgressView(value: 2, total: 3, status: Status.hung)
}
