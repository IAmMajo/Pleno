//
//  WrappedLayoutView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 19.01.25.
//

import SwiftUI

import SwiftUI

struct WrappedLayoutView: View {
    var items: [String]
    let colors: [Color]

   var body: some View {
      let colorSequence = items.enumerated().map { colors[$0.offset % colors.count] }
      let rows = createRows()
      
      VStack(alignment: .center, spacing: 8) {
//         ForEach(rows.indices, id: \.self) { rowIndex in
//            HStack(spacing: 8) {
//               ForEach(rows[rowIndex].indices, id: \.self) { columnIndex in
//                  let globalIndex = rows[..<rowIndex].reduce(0) { $0 + rows[$1].count } + columnIndex
//                  let item = rows[rowIndex][columnIndex]
//                  self.item(for: item, color: colors[globalIndex % colors.count])
//               }
//            }
//            .frame(maxWidth: .infinity, alignment: .center) // Align items in the center
//         }
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
//         ForEach(rows.indices, id: \.self) { rowIndex in
//            HStack(spacing: 8) {
//               ForEach(rows[rowIndex].indices, id: \.self) { itemIndex in
//                  let item = rows[rowIndex][itemIndex]
//                  self.item(for: item, color: colorSequence[rowIndex * rows[rowIndex].count + itemIndex])
//               }
//            }
//            .frame(maxWidth: .infinity, alignment: .center) // Align items in the center
//         }
      }
      .fixedSize(horizontal: false, vertical: true) // Ensure the view wraps content size
   }
   
   private func createRows() -> [[String]] {
      var rows: [[String]] = []
      var currentRow: [String] = []
      var currentRowWidth: CGFloat = 0
      let totalWidth: CGFloat = UIScreen.main.bounds.width - 32 // Estimate available width
      
      for item in items {
         let itemWidth = platformWidth(for: item)
         
         if currentRowWidth + itemWidth > totalWidth {
            rows.append(currentRow)
            currentRow = [item]
            currentRowWidth = itemWidth
         } else {
            currentRow.append(item)
            currentRowWidth += itemWidth
         }
      }
      
      if !currentRow.isEmpty {
         rows.append(currentRow)
      }
      
      return rows
   }
   
   private func platformWidth(for text: String) -> CGFloat {
      let font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
      let attributes = [NSAttributedString.Key.font: font]
      let size = (text as NSString).size(withAttributes: attributes)
      return size.width + 10
   }
   
   func item(for text: String, color: Color) -> some View {
      HStack(spacing: 4) {
         Circle()
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
