import SwiftUI

struct ContentView: View {
    var body: some View {
        MenuView()
    }
}

struct MenuView: View {
    
    enum PresentView {
        case menu
        case play
        case count
        case assist
    }
    
    @State private var presentedView: PresentView = .menu
    
    @ViewBuilder var menuBody: some View {
        VStack {
            Button("Play") {
                presentedView = .play
            }
            Button("Count") {
                presentedView = .count
            }
            Button("Assist") {
                presentedView = .assist
            }
        }
    }
    
    var body: some View {
        switch presentedView {
        case .menu:
            menuBody
        case .play:
            Text("Playing...")
        case .count:
            CountAppView(exitClosure: {
                self.presentedView = .menu
            })
        case .assist:
            Text("Assist...")
        }
    }
}
