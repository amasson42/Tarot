import SwiftUI
import UIKit

struct UIViewControllerRepresented<VC: UIViewController>: UIViewControllerRepresentable {

    typealias UIViewControllerType = VC
    
    var view: () -> VC
    var update: (VC, Context) -> () = { _, _ in }
    
    func makeUIViewController(context: Context) -> VC {
        view()
    }
    
    func updateUIViewController(_ uiViewController: VC, context: Context) {
        update(uiViewController, context)
    }
}
