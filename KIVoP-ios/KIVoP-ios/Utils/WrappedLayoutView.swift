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
//  WrappedLayoutView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 19.01.25.
//

import SwiftUI

/// A SwiftUI view that arranges items in a wrapped layout based on available screen width
struct WrappedLayoutView: View {
   // MARK: - Properties
    var items: [String] /// The list of text items to be displayed
    let colors: [Color] /// The corresponding colors for each item
 
   // MARK: - Body
   var body: some View {
      // Generates a color sequence for each item by cycling through the provided colors
      let colorSequence = items.enumerated().map { colors[$0.offset % colors.count] }
      // Creates an array of rows, each containing items that fit within the available width
      let rows = createRows()
      
      VStack(alignment: .center, spacing: 8) {
         ForEach(rows.indices, id: \.self) { rowIndex in
            HStack(spacing: 8) {
               ForEach(rows[rowIndex], id: \.self) { item in
                  if let itemIndex = items.firstIndex(of: item) {
                     self.item(for: item, color: colorSequence[itemIndex])
                  }
               }
            }
            .frame(maxWidth: .infinity, alignment: .center) // Align items in the center
         }
      }
      .fixedSize(horizontal: false, vertical: true) // Ensure the view wraps content size
   }
   
   // MARK: - Creating Rows
   /// Groups items into rows based on available screen width.
   private func createRows() -> [[String]] {
      var rows: [[String]] = []
      var currentRow: [String] = []
      var currentRowWidth: CGFloat = 0
      let totalWidth: CGFloat = UIScreen.main.bounds.width - 32 // Define available screen width with padding
      
      for item in items {
         let itemWidth = platformWidth(for: item)
         
         // If adding another item exceeds available width, start a new row
         if currentRowWidth + itemWidth > totalWidth {
            rows.append(currentRow)
            currentRow = [item]
            currentRowWidth = itemWidth
         } else {
            currentRow.append(item)
            currentRowWidth += itemWidth
         }
      }
      
      // Append the last row if not empty
      if !currentRow.isEmpty {
         rows.append(currentRow)
      }
      
      return rows
   }
   
   // MARK: - Calculating Text Width
   /// Estimates the width of a given text string based on system font size
   private func platformWidth(for text: String) -> CGFloat {
      let font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
      let attributes = [NSAttributedString.Key.font: font]
      let size = (text as NSString).size(withAttributes: attributes)
      return size.width + 10 // Adds padding for spacing
   }
   
   // MARK: - Item View
   /// Creates a labeled item view with a circular color indicator
   func item(for text: String, color: Color) -> some View {
      HStack(spacing: 4) {
         Circle() // Small colored indicator
            .fill(color)
            .frame(width: 10, height: 10)
         Text(text)
            .font(.footnote)
            .foregroundStyle(Color(UIColor.secondaryLabel))
      }
   }
}


#Preview {
   WrappedLayoutView(
      items: ["Enthaltung", "Weizenbrötchen", "Vollkornbrötchen", "Milchbrötchen"],
      colors: [.red, .green, .blue, .teal, .purple, .yellow]
   )
}
