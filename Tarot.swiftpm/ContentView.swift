import SwiftUI

struct ContentView: View {
    var body: some View {
        MenuView()
    }
}

struct MenuView: View {
    
    var body: some View {
        NavigationView {
            VStack {

                NavigationLink(destination: GenericCountView()) {
                    Text("Generic")
                }
                .tarotButton()

                NavigationLink(destination: TarotAppRootView()) {
                    Text("Tarot")
                }
                .tarotButton()

                NavigationLink(destination: JetonsBoardView()) {
                    Text("Jetons")
                }
                .tarotButton()

            }
            .navigationTitle("Menu")
        }
        .navigationViewStyle(.stack)
    }
    
}
