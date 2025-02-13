// This file is licensed under the MIT-0 License.
//
//  FunctionHelper.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 22.01.25.
//

import Foundation
import PosterServiceDTOs
import SwiftUICore
import UIKit

struct DateColorHelper {
   // returns color to display for a positions expiresAt date
  static func getDateColor(position: PosterPositionResponseDTO) -> Color {
      let status = position.status
      switch status {
      case .hangs:
         if position.expiresAt < Calendar.current.date(byAdding: .day, value: 1, to: Date())! {
            return .orange
         } else {
            return Color(UIColor.secondaryLabel)
         }
      case .overdue:
         return .red
      default:
         return Color(UIColor.secondaryLabel)
      }
   }
}
