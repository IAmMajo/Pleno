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



import Foundation

// Funktionen um ein einheitliches Datums- und Zeitformat einzustellen
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
