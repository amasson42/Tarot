import SwiftUI

struct ContentView: View {
    var body: some View {
        MenuView()
    }
}

struct MenuView: View {
    
    enum PresentView {
        case menu
        case generic
        case count
        case sept
    }
    
    @State private var presentedView: PresentView = .menu
    
    @ViewBuilder var menuBody: some View {
        VStack {
            Button("Generic") {
                presentedView = .generic
            }
            Button("Tarot") {
                presentedView = .count
            }
            Button("Sept et demi") {
                presentedView = .sept
            }
        }
    }
    
    var body: some View {
        switch presentedView {
        case .menu:
            menuBody
        case .generic:
            GenericCountView(exitClosure: {
                self.presentedView = .menu
            })
        case .count:
            TarotCountView(exitClosure: {
                self.presentedView = .menu
            })
        case .sept:
            Text("Let's play !")
        }
    }
}
