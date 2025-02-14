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
import CoreImage.CIFilterBuiltins

struct QRCodeImage: View {
    let data: Data
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var qrCode: UIImage {
        filter.message = self.data
        
        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    init(data: Data) {
        self.data = data
    }
    init(dataString: String) {
        self.data = Data(dataString.utf8)
    }
    
    var body: some View {
        Image(uiImage: qrCode)
            .interpolation(.none)
            .resizable()
            .scaledToFit()
    }

}

#Preview {
    @Previewable @State var dataString = "123456"
    NavigationStack {
        Form {
            Section("Output") {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    QRCodeImage(dataString: dataString)
                } else {
                    HStack {
                        Spacer()
                        QRCodeImage(dataString: dataString)
                            .frame(width: 400, height: 400)
                        Spacer()
                    }
                }
            }
            Section("Input") {
                TextField("QR-Code Daten", text: $dataString)
            }
        }
        .navigationTitle("QR-Code (Beispiel)")
    }
}
