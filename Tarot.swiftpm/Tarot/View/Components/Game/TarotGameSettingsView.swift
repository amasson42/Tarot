import SwiftUI

struct TarotGameSettingsView: View {
    @ObservedObject var game: TarotGame

    var body: some View {
        TarotGameParametersView(
            playerNameBinds: $game.players.map { $0 },
            gameName: $game.name,
            gameColor: $game.color)
    }
}

struct TarotGameSettingsButton: View {
    @ObservedObject var game: TarotGame

    @State private var showSettings: Bool = false

    var body: some View {
        Button {
            self.showSettings = true
        } label: {
            Image(systemName: "gearshape")
        }
        .tarotButton()
        .sheet(isPresented: $showSettings, onDismiss: {
            
        }, content: {
            ZStack {
                TarotGameSettingsView(game: self.game)
                
                HStack {
                    Spacer()
                    VStack {
                        Image(systemName: "xmark")
                            .padding()
                            .onTapGesture {
                                self.showSettings = false
                            }
                        Spacer()
                    }
                }
            }
        })
    }
}
