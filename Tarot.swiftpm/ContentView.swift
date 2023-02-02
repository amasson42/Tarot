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
        case tarot
        case jetons
    }
    
    @State private var presentedView: PresentView = .menu
    
    @ViewBuilder var menuBody: some View {
        VStack {
            Button("Generic") {
                presentedView = .generic
            }
            Button("Tarot") {
                presentedView = .tarot
            }
            Button("Jetons") {
                presentedView = .jetons
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
        case .tarot:
            TarotCountView(exitClosure: {
                self.presentedView = .menu
            })
        case .jetons:
            JetonsBoardView(exitClosure: { 
                self.presentedView = .menu
            })
        }
    }
}
