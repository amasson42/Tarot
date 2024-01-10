//
//  File.swift
//
//
//  Created by Giantwow on 09/01/2024.
//

import SwiftUI
import UIKit

public struct ShareItemButton<Label>: View where Label: View {
    
    public var label: () -> Label
    public var item: () -> Any
    
    @State private var activityViewController: UIActivityViewController?
    
    public var body: some View {
        Button(action: self.shareItem, label: self.label)
            .sheet(isPresented: Binding<Bool>(
                get: {
                    self.activityViewController != nil
                },
                set: { v in
                    if v {
                        self.shareItem()
                    } else {
                        self.activityViewController = nil
                    }
                }), content: {
                    UIViewControllerRepresented {
                        self.activityViewController!
                    }
                })
    }
    
    @MainActor
    func shareItem() {
        let sharedItem = self.item()
        self.activityViewController = UIActivityViewController(activityItems: [sharedItem], applicationActivities: nil)
    }
}

extension ShareItemButton where Label == Image {
    
    init(item: @escaping () -> Any) {
        self.item = item
        self.label = {
            Image(systemName: "square.and.arrow.up")
        }
    }
}

#Preview {
    ShareItemButton {
        Image(systemName: "photo")
    }
}
