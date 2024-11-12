//
//  DateFormatHelper.swift
//  PawFriends
//
//  Created by Til Anheier on 05.07.24.
//

import Foundation

struct DateTimeFormatter {
   
   static func formatDate(_ date: Date) -> String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "dd.MM.yyyy"
      return dateFormatter.string(from: date)
   }
   
   static func formatTime(_ date: Date) -> String {
      let timeFormatter = DateFormatter()
      timeFormatter.dateFormat = "HH:mm"
      return timeFormatter.string(from: date)
   }
}
