import SwiftUI

struct TarotGameCreationView: View {
    
    var createAction: ((TarotGame) -> ())? = nil
    
    @AppStorage("tarot_playerName0") private var playerName0 = ""
    @AppStorage("tarot_playerName1") private var playerName1 = ""
    @AppStorage("tarot_playerName2") private var playerName2 = ""
    @AppStorage("tarot_playerName3") private var playerName3 = ""
    @AppStorage("tarot_playerName4") private var playerName4 = ""
    
    @State private var gameName = ""
    @State private var gameColor = Color.randomTheme()
    
    var playerNamesBind: [Binding<String>] {
        [$playerName0, $playerName1, $playerName2, $playerName3, $playerName4]
    }
    
    var playerNames: [String] {
        playerNamesBind.map(\.wrappedValue).filter { !$0.isEmpty }
    }
    
    var body: some View {
        
        VStack {
            
            TarotGameParametersView(playerNameBinds: playerNamesBind, gameName: $gameName, gameColor: $gameColor)
            
            HStack {
                
                Button {
                    if let game = createGame() {
                        createAction?(game)
                    }
                } label: {
                    VStack {
                        Image(systemName: "play.fill")
                        Text("Start")
                    }
                }
                .tarotButton()
                .disabled(!canCreateGame())
                
            }
            .padding()
            
        }
        .navigationTitle("Player Setup")
        .navigationBarHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
    }
    
    func canCreateGame() -> Bool {
        createGame() != nil
    }
    
    func createGame() -> TarotGame? {
        TarotGame(
            players: playerNames,
            name: gameName,
            color: gameColor,
            createdDate: .now
        )
    }
}

#Preview {
    TarotGameCreationView()
}
