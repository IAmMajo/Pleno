//
//  QRCodeScannerView.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 03.12.24.
//

import SwiftUI
import UIKit

struct QRCodeScannerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = QRCodeScannerViewController
    var onCodeFound: (String) -> Void

    func makeUIViewController(context: Context) -> QRCodeScannerViewController {
        let scannerVC = QRCodeScannerViewController()
        scannerVC.onCodeFound = onCodeFound // Übergabe der Callback-Funktion
        return scannerVC
    }

    func updateUIViewController(_ uiViewController: QRCodeScannerViewController, context: Context) {
        // Keine Aktualisierung erforderlich
    }
}
