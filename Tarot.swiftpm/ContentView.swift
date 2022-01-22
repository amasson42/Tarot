import SwiftUI

struct ContentView: View {
    var body: some View {
        //MenuView()
        CountAppView()
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
        ZStack {
            if presentedView == .menu {
                menuBody
            }
            if presentedView == .play {
                Text("Playing...")
            }
            if presentedView == .count {
                CountAppView(exitClosure: {
                    self.presentedView = .menu
                })
            }
            if presentedView == .assist {
                Text("Assisting...")
            }
        }
    }
}
