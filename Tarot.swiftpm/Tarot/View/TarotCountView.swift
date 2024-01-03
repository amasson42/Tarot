import SwiftUI

/// Root view for the Couting App feature
/// Can setup the players, retrieve a previous game and start couting
struct TarotCountView: View {
    
    var exitClosure: (() -> ())?
    @AppStorage("tarot_playerName0") var playerName0 = ""
    @AppStorage("tarot_playerName1") var playerName1 = ""
    @AppStorage("tarot_playerName2") var playerName2 = ""
    @AppStorage("tarot_playerName3") var playerName3 = ""
    @AppStorage("tarot_playerName4") var playerName4 = ""
    
    @State private var game: TarotGame?
    @State private var selectOldGameActive: Bool = false
    @State private var gameActive: Bool = false
    
    var playerNamesBind: [Binding<String>] {
        [$playerName0, $playerName1, $playerName2, $playerName3, $playerName4]
    }
    var playerNames: [String] {
        playerNamesBind.map(\.wrappedValue).filter { !$0.isEmpty }
    }
    func setPlayerNames(_ names: [String]) {
        for i in playerNamesBind.indices {
            playerNamesBind[i].wrappedValue = names.count > i ? names[i] : ""
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                
                Spacer()
                
                VStack {
                    ForEach(playerNamesBind.indices, id: \.self) {
                        i in
                        TextField("empty spot", text: playerNamesBind[i])
                            .playerNameBox(active: !(game?.rounds.isEmpty ?? true))
                            .disableAutocorrection(true)
                            .textInputAutocapitalization(.words)
                            .padding(.horizontal)
                            .tag(i)
                    }
                    .onChange(of: playerNames) { nv in
                        if self.game?.players.count == nv.count {
                            self.game?.players = playerNames
                        } else {
                            self.game = nil
                        }
                    }
                }
                
                HStack {
                    
                    NavigationLink(isActive: $selectOldGameActive) { 
                        TarotSelectOldGameView(gameManager: TarotGameManager_LocalFiles()) { game in
                            self.setPlayerNames(game.players)
                            self.selectOldGameActive = false
                            DispatchQueue.main.async {
                                self.game = game
                            }
                        }
                    } label: {
                        VStack {
                            Image(systemName: "list.dash")
                            Text("Games")
                        }
                    }
                    .tarotButton()
                    
                    Button {
                        if self.game == nil {
                            self.game = TarotGame(players: self.playerNames)
                        }
                        self.gameActive = true
                    } label: {
                        VStack {
                            Image(systemName: "play.fill")
                            Text("Start")
                        }
                    }
                    .tarotButton()
                    
                    if let game = self.game {
                        
                        NavigationLink(destination: TarotTableView()
                                        .environmentObject(game)
                                        .navigationTitle(game.name)
                                        .onDisappear {
                            do {
                                if !game.rounds.isEmpty {
                                    try TarotGameManager_LocalFiles().save(game: game)
                                }
                            } catch {
                                print("error saving game \(game.name): \(error.localizedDescription)")
                            }
                        }
                                       , isActive: $gameActive, label: {
                            EmptyView()
                        })
                        
                    }
                    
                }
                .padding()
                
                Spacer()
                
                if let exitClosure = exitClosure {
                    Button("Exit", action: exitClosure)
                        .padding()
                }
                
            }
            .navigationTitle("Player Setup")
            .navigationBarHidden(true)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Text("Pick the player names")
        }
    }
    
}

#Preview {
    TarotCountView()
}
