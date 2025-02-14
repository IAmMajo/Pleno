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
//  Polls-CreatePollView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 18.01.25.
//

import SwiftUI
import PollServiceDTOs

// A view for creating a new poll
struct Polls_CreatePollView: View {
   @Environment(\.dismiss) var dismiss
   @State private var question: String = "" // Stores the poll question
   @State private var description: String = "" // Stores the poll description
   @State private var options: [String] = [""] // Stores the list of poll options
   @State private var deadline: Date = Date() // Stores the poll closing date
   @State private var showDatePicker: Bool = false // Controls visibility of the date picker.
   @State private var allowsMultipleSelections: Bool = false // Indicates if multiple selections are allowed
   @State private var isAnonymous: Bool = false // Indicates if the poll is anonymous
   @State private var isLoading: Bool = false // Indicates if the poll is being created
   @State private var errorMessage: String? // Stores an error message if poll creation fails

   /// Callback function executed when a poll is successfully created
   let onSave: () -> Void

   var body: some View {
       NavigationView {
           Form {
              // MARK: - General Information Section
               Section(header: Text("Allgemeine Informationen")) {
                   TextField("Frage", text: $question)
                   TextField("Beschreibung", text: $description)
                       .onChange(of: description) { oldValue, newValue in
                          // Limits the description to 300 characters
                           if newValue.count > 300 {
                               description = String(newValue.prefix(300))
                           }
                       }
               }

              // MARK: - Options Section
               Section(header: Text("Auswahlmöglichkeiten")) {
                   ForEach(options.indices, id: \.self) { index in
                       HStack {
                           TextField("Option \(index + 1)", text: $options[index])
                               .onChange(of: options[index]) { oldValue, newValue in
                                  // Adds a new empty option when the last field is edited
                                   if !newValue.isEmpty && index == options.count - 1 {
                                       options.append("")
                                   }
                               }
                          // Shows delete button if there is more than one option
                           if options.count > 1 {
                               Button(action: {
                                   options.remove(at: index)
                               }) {
                                   Image(systemName: "trash")
                                       .foregroundColor(.red)
                               }
                           }
                       }
                   }
               }

              // MARK: - Poll Settings Section
               Section(header: Text("Optionen")) {
                   Toggle("Mehrfachauswahl erlauben", isOn: $allowsMultipleSelections)
                   Toggle("Anonymisierung aktivieren", isOn: $isAnonymous)
               }

              // MARK: - Deadline Section
               Section(header: Text("Abschlusszeit")) {
                   HStack {
                       Text("Ende:")
                       Spacer()
                       Button(action: {
                           withAnimation {
                               showDatePicker.toggle() // Toggles date picker visibility
                           }
                       }) {
                           HStack {
                               Text(deadline, style: .date) // Displays selected date
                               Text(deadline, style: .time) // Displays selected time
                           }
                           .padding(8)
                           .background(Color(UIColor.systemGray6))
                           .cornerRadius(8)
                       }
                   }

                   if showDatePicker {
                       DatePicker(
                           "Datum und Uhrzeit",
                           selection: $deadline,
                           displayedComponents: [.date, .hourAndMinute]
                       )
                       .datePickerStyle(GraphicalDatePickerStyle())
                   }
               }

              // MARK: - Error Message Section
               if let errorMessage = errorMessage {
                   Section {
                       Text(errorMessage)
                           .foregroundColor(.red)
                           .font(.footnote)
                   }
               }
           }
           .navigationTitle("Umfrage erstellen")
          // MARK: - Toolbar Buttons
           .toolbar {
               ToolbarItem(placement: .navigationBarTrailing) {
                  // Save Button
                   Button(action: createPoll) {
                       if isLoading {
                           ProgressView()
                       } else {
                           Text("Erstellen")
                       }
                   }
                   .disabled(question.isEmpty || options.filter({ !$0.isEmpty }).count < 2)
               }
              
              // Cancel Button
               ToolbarItem(placement: .navigationBarLeading) {
                   Button("Abbrechen") {
                       dismiss()
                   }
               }
           }
       }
   }
   
   // MARK: - Helper Functions
      
   /// Creates a new poll by sending data to the API
   private func createPoll() {
       isLoading = true
       errorMessage = nil

      // Filters out empty options and trims whitespace
       let validOptions = options.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
       let pollOptions = validOptions.enumerated().map { GetPollVotingOptionDTO(index: UInt8($0.offset + 1), text: $0.element) }

      // Creates a new poll object
       let newPoll = CreatePollDTO(
           question: question.trimmingCharacters(in: .whitespacesAndNewlines),
           description: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "" : description.trimmingCharacters(in: .whitespacesAndNewlines),
           closedAt: deadline,
           anonymous: isAnonymous,
           multiSelect: allowsMultipleSelections,
           options: pollOptions
       )

      // Sends the poll data to the backend
       PollAPI.shared.createPoll(poll: newPoll) { result in
           DispatchQueue.main.async {
               isLoading = false
               switch result {
               case .success:
                   onSave()  // Notify parent view
                   dismiss() // Close the view
               case .failure(let error):
                   errorMessage = error.localizedDescription
                   print("Fehler beim Erstellen: \(error.localizedDescription)")
               }
           }
       }
   }
}

