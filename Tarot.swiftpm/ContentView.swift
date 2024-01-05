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
                NavigationLink(destination: TarotAppRootView()) {
                    Text("Tarot")
                }
                NavigationLink(destination: JetonsBoardView()) {
                    Text("Jetons")
                }
            }
            .navigationTitle("Menu")
            
        }
        .navigationViewStyle(.stack)
    }
    
}
