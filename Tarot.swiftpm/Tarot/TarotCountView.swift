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
    
    @State private var gameList: TarotGameList?
    @State private var selectOldGameActive: Bool = false
    @State private var gameListActive: Bool = false
    
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
                            .playerNameBox(active: !(gameList?.gameHistory.isEmpty ?? true))
                            .disableAutocorrection(true)
                            .textInputAutocapitalization(.words)
                            .padding(.horizontal)
                            .tag(i)
                    }
                    .onChange(of: playerNames) { nv in
                        self.gameList = nil
                    }
                }
                
                HStack {
                    
                    NavigationLink(isActive: $selectOldGameActive) { 
                        TarotSelectOldGameView { game in
                            self.setPlayerNames(game.players)
                            self.selectOldGameActive = false
                            DispatchQueue.main.async {
                                self.gameList = game
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
                        if self.gameList == nil {
                            self.gameList = TarotGameList(players: self.playerNames)
                        }
                        self.gameListActive = true
                    } label: {
                        VStack {
                            Image(systemName: "play.fill")
                            Text("Start")
                        }
                    }
                    .tarotButton()
                    
                    if let gameList = self.gameList {
                        
                        NavigationLink(destination: TarotTableView()
                                        .environmentObject(gameList)
                                        .navigationTitle(gameList.name)
                                        .onDisappear {
                            do {
                                if !gameList.gameHistory.isEmpty {
                                    try gameList.save()
                                }
                            } catch {
                                print("error saving game \(gameList.name): \(error.localizedDescription)")
                            }
                        }
                                       , isActive: $gameListActive, label: {
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

struct TarotCountView_Previews: PreviewProvider {
    static var previews: some View {
        TarotCountView()
    }
}
