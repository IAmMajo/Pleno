//
//  SelectableTextView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 30.12.24.
//

import SwiftUI

//struct SelectableTextView: UIViewRepresentable {
//   let text: String
//   
//   class Coordinator: NSObject {
//      var parent: SelectableTextView
//      
//      init(parent: SelectableTextView) {
//         self.parent = parent
//      }
//      
//      @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
//         guard gestureRecognizer.state == .began else { return }
//         
//         // Get the UITextView and select all text
//         if let textView = gestureRecognizer.view as? UITextView {
//            textView.selectAll(nil)
//            
//            let impact = UIImpactFeedbackGenerator(style: .medium)
//            impact.impactOccurred()
//         }
//      }
//   }
//   
//   func makeUIView(context: Context) -> UITextView {
//      let textView = UITextView()
//      textView.isEditable = false
//      textView.isSelectable = true
//      textView.text = text
//      textView.font = UIFont.preferredFont(forTextStyle: .body)
//      textView.backgroundColor = UIColor.clear
//      textView.textAlignment = .left
//      textView.isScrollEnabled = false
//      // Remove internal padding by setting textContainerInset to zero
//      textView.textContainerInset = UIEdgeInsets.zero
//            
//      // Add long press gesture recognizer to select all text
//      let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLongPress(_:)))
//      textView.addGestureRecognizer(longPressGesture)
//      
//      return textView
//   }
//   
//   func updateUIView(_ uiView: UITextView, context: Context) {
//      uiView.text = text
//      uiView.sizeToFit() // Dynamically adjust the height based on the text
//   }
//   
//   func makeCoordinator() -> Coordinator {
//      return Coordinator(parent: self)
//   }
//}

import SwiftUI

struct SelectableTextView: UIViewRepresentable {
    let text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false // Not editable
        textView.isSelectable = true // Allows selection
        textView.text = text
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.backgroundColor = UIColor.clear
        textView.textAlignment = .left
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero // Remove extra padding
        textView.textContainer.lineFragmentPadding = 0 // Remove left-right padding

        // Add long press gesture for selecting text
        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleLongPress(_:)))
        textView.addGestureRecognizer(longPressGesture)

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: SelectableTextView
        private var tapGestureRecognizer: UITapGestureRecognizer?

        init(_ parent: SelectableTextView) {
            self.parent = parent
        }

        @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            guard let textView = gesture.view as? UITextView else { return }
            if gesture.state == .began {
                // Select all text in the text view
                textView.selectAll(nil)

                // Show the copy menu
                let menu = UIMenuController.shared
                menu.showMenu(from: textView, rect: textView.bounds)

                // Add tap gesture recognizer globally
                addGlobalTapGesture()
            }
        }

        private func addGlobalTapGesture() {
            guard let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow }) else { return }

            // Add a tap gesture recognizer to the window
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGlobalTap(_:)))
            tapGesture.cancelsTouchesInView = false // Allow normal interactions
            window.addGestureRecognizer(tapGesture)
            tapGestureRecognizer = tapGesture
        }

        @objc func handleGlobalTap(_ gesture: UITapGestureRecognizer) {
            guard let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow }) else { return }

            // Find the text view and clear its selection
            for subview in window.subviews {
                if let textView = findTextView(in: subview) {
                    textView.selectedTextRange = nil
                }
            }

            // Remove the tap gesture recognizer after use
            if let tapGesture = tapGestureRecognizer {
                window.removeGestureRecognizer(tapGesture)
                tapGestureRecognizer = nil
            }
        }

        private func findTextView(in view: UIView) -> UITextView? {
            if let textView = view as? UITextView {
                return textView
            }
            for subview in view.subviews {
                if let textView = findTextView(in: subview) {
                    return textView
                }
            }
            return nil
        }
    }
}



//struct SelectableTextView: UIViewRepresentable {
//    let text: String
//
//    func makeUIView(context: Context) -> UITextView {
//        let textView = UITextView()
//        textView.isEditable = false
//        textView.isSelectable = true
//        textView.text = text
//        textView.font = UIFont.preferredFont(forTextStyle: .body)
//        textView.backgroundColor = UIColor.clear
//        textView.textAlignment = .left
//        textView.isScrollEnabled = false
//        textView.textContainerInset = .zero // Remove extra padding
//        textView.textContainer.lineFragmentPadding = 0 // Remove left-right padding
////        textView.tintColor = .clear // Makes selection invisible
//
//        // Add UIEditMenuInteraction for menu handling
//        let interaction = UIEditMenuInteraction(delegate: context.coordinator)
//        textView.addInteraction(interaction)
//
//        return textView
//    }
//
//    func updateUIView(_ uiView: UITextView, context: Context) {
//        uiView.text = text
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: NSObject, UIEditMenuInteractionDelegate {
//        var parent: SelectableTextView
//
//        init(_ parent: SelectableTextView) {
//            self.parent = parent
//        }
//
//       func editMenuInteraction(_ interaction: UIEditMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIEditMenuConfiguration? {
//          guard let textView = interaction.view as? UITextView else { return nil }
//          
//          // Programmatically select all text
//          textView.selectedRange = NSRange(location: 0, length: textView.text.count)
//          
//          // Define actions for the menu
////          let copyAction = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { _ in
////             UIPasteboard.general.string = textView.text
////          }
//          
//          // Return the menu configuration with only the "Copy" action
////          return UIEditMenuConfiguration(identifier: nil, sourcePoint: location, menu: UIMenu(children: [copyAction]))
//          return UIEditMenuConfiguration(identifier: nil, sourcePoint: location)
//       }
//    }
//}

struct LongPressToCopyView: View {
   let text: String
   @State private var isLongPressed = false
   @State private var selectedText = ""
      
   var body: some View {
      Text(text)
         .padding()
         .frame(maxWidth: .infinity, alignment: .leading)
      //            .background(isLongPressed ? Color.blue.opacity(0.3) : Color.clear)
         .onLongPressGesture {
            isLongPressed = true
            selectedText = text
         }
         .contextMenu {
            if isLongPressed {
               Button(action: {
                  UIPasteboard.general.string = selectedText
                  isLongPressed = false
               }) {
                  Label("Copy", systemImage: "doc.on.doc")
                  //                          .background(Color(UIColor.secondarySystemBackground))
               }
            }
         }
    }
}

#Preview {
   Text("test")
   SelectableTextView(text: "Hochschule\n12345 Stadt\n Land")
      .frame(maxWidth: .infinity, alignment: .leading)
      .fixedSize(horizontal: false, vertical: true)
      .border(.pink)
   Text("test")
   LongPressToCopyView(text: "Hochschule\n12345 Stadt\n Land")
}
