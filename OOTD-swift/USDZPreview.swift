//
//  USDZPreview.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 6/17/25.
//
import SwiftUI
import QuickLook

struct USDZPreview: UIViewControllerRepresentable {
    let usdzURL: URL

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(usdzURL: usdzURL)
    }

    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let usdzURL: URL

        init(usdzURL: URL) {
            self.usdzURL = usdzURL
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return usdzURL as QLPreviewItem
        }
    }
}
