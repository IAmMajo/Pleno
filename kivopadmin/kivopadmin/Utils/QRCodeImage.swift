//
//  QRCodeImage.swift
//  kivopadmin
//
//  Created by Lennart Guggenberger on 10.12.24.
//

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
