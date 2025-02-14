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



import SwiftUI
import MarkdownUI

struct ExtendRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var markdownText: String
    @State private var aiGeneratedText: String = "" // Unformatierter KI-Text
    @State private var formattedText: String = "" // Formatierter KI-Text
    @State private var userEditedText: String = "" // Bearbeiteter Text
    @State private var isLoading = true
    @State private var isEditing = false // Bearbeitungsmodus
    var lang: String

    var body: some View {
        VStack(spacing: 20) {
            // **Titel-Leiste mit Zurück & Speichern**
            HStack {
                if isEditing {
                    Button("Zurück") {
                        isEditing = false
                        userEditedText = aiGeneratedText
                        formattedText = formatMarkdown(aiGeneratedText)
                    }
                    .foregroundColor(.blue)
                }
                Spacer()
                Text("KI-generierte Verbesserung")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
                Button(action: {
                    isEditing.toggle()
                    if !isEditing {
                        aiGeneratedText = userEditedText
                        formattedText = formatMarkdown(userEditedText)
                    }
                }) {
                    HStack {
                        if isEditing {
                            Text("Speichern")
                                .font(.system(size: 18))
                        } else {
                            Image(systemName: "pencil")
                                .font(.system(size: 18, weight: .bold))
                        }
                    }
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .frame(height: 44)

            HStack(spacing: 20) {
                VStack {
                    Text("Originaltext")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    TextEditor(text: $markdownText)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 300)
                        .cornerRadius(8)
                        .border(Color.gray, width: 1)
                }
                VStack {
                    Text("KI-Vorschlag")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    if isLoading {
                        TextEditor(text: $aiGeneratedText)
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 300)
                            .background(Color.white)
                            .cornerRadius(8)
                            .border(Color.gray, width: 1)
                    } else if isEditing {
                        TextEditor(text: $userEditedText)
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 300)
                            .background(Color.white)
                            .cornerRadius(8)
                            .border(Color.gray, width: 1)
                    } else {
                        ScrollView {
                            Markdown(formattedText)
                                .markdownTheme(.basic)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .background(Color.white)
                        .cornerRadius(8)
                        .border(Color.gray, width: 1)
                    }
                }
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            Spacer()
            HStack(spacing: 15) {
                Button(action: {
                    dismiss()
                }) {
                    Text("Verwerfen")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                Button(action: {
                    markdownText = formattedText
                    dismiss()
                }) {
                    Text("Übernehmen")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .frame(minWidth: 1200, maxWidth: 2800)
        .task {
            await fetchExtendedRecord()
        }
    }

    private func fetchExtendedRecord() async {
        isLoading = true
        aiGeneratedText = ""

        await RecordsAPI.extendRecord(content: markdownText, lang: lang) { chunk in
            DispatchQueue.main.async {
                aiGeneratedText += chunk + "\n"
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("Finaler AI-Text:\n\(aiGeneratedText)")
            formattedText = formatMarkdown(aiGeneratedText)
            userEditedText = aiGeneratedText
            isLoading = false
        }
    }

    private func formatMarkdown(_ text: String) -> String {
        var formattedText = text
        formattedText = formattedText.replacingOccurrences(of: "### ", with: "\n### ")
        formattedText = formattedText.replacingOccurrences(of: "## ", with: "\n## ")
        //formattedText = formattedText.replacingOccurrences(of: "# ", with: "\n# ")
        formattedText = formattedText.replacingOccurrences(of: "- ", with: "\n- ")
        formattedText = formattedText.replacingOccurrences(of: "---", with: "\n\n—\n\n")
        formattedText = formattedText.replacingOccurrences(of: "\n\n\n", with: "\n\n")
        return formattedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}



struct SocialMediaPostView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var socialMediaText: String = ""
    @State private var isLoading = true
    var markdownText: String
    var lang: String

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    Text(socialMediaText.isEmpty ? "Lade Social-Media-Post..." : removeMarkdownSyntax(from: socialMediaText))
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: sharePost) {
                    Label("Teilen", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .background(Color.white)
            .task {
                await fetchSocialMediaPost()
            }
            .navigationTitle("Generierter Social-Media-Post") // **Mittiger Titel**
            .navigationBarTitleDisplayMode(.inline) // **Sorgt für eine perfekte zentrierte Darstellung**
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
    
    private func fetchSocialMediaPost() async {
        isLoading = true
        socialMediaText = ""
        
        await RecordsAPI.generateSocialMediaPost(content: markdownText, lang: lang) { chunk in
            DispatchQueue.main.async {
                socialMediaText += chunk + " "
            }
        }
        
        isLoading = false
    }
    
    private func sharePost() {
        let activityController = UIActivityViewController(activityItems: [socialMediaText], applicationActivities: nil)
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = scene.windows.first?.rootViewController {
            rootViewController.present(activityController, animated: true, completion: nil)
        }
    }
    
    private func removeMarkdownSyntax(from text: String) -> String {
        var cleanedText = text

        // **Markdown entfernen**
        cleanedText = cleanedText.replacingOccurrences(of: "# ", with: "")
        cleanedText = cleanedText.replacingOccurrences(of: "## ", with: "")
        cleanedText = cleanedText.replacingOccurrences(of: "### ", with: "")
        cleanedText = cleanedText.replacingOccurrences(of: "**", with: "")
        cleanedText = cleanedText.replacingOccurrences(of: "*", with: "")
        cleanedText = cleanedText.replacingOccurrences(of: "- ", with: "")
        cleanedText = cleanedText.replacingOccurrences(of: "---", with: "")
        cleanedText = cleanedText.replacingOccurrences(of: "—", with: "")
        cleanedText = cleanedText.trimmingCharacters(in: CharacterSet(charactersIn: "\"“”„"))

        return cleanedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

}
