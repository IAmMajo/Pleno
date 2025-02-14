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
