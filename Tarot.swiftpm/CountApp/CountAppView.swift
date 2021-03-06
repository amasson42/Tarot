import SwiftUI

/// Root view for the Couting App feature
/// Can setup the players, retrieve a previous game and start couting
struct CountAppView: View {
    
    var exitClosure: (() -> ())?
    @State private var playerList: [String] = []
    @State private var playerInputActive: Bool = false
    @State private var selectOldGameActive: Bool = false
    
    @State private var gameList: TarotGameList?
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    
                    Button("Set players") {
                        playerInputActive = true
                    }
                    
                    VStack {
                        Text("Players")
                        HStack {
                            ForEach(playerList.indices, id: \.self) { i in
                                Text(playerList[i])
                                    .lineLimit(1)
                                    .frame(height: 20)
                                    .playerNameBox(active: false)
                                    .minimumScaleFactor(0.01)
                            }
                        }
                        .background(Color.gray.opacity(0.3))
                    }
                    
                    NavigationLink("Games", isActive: $selectOldGameActive) {
                        CountAppSelectOldGameView {
                            self.gameList = $0
                            self.playerList = $0.players
                            UserDefaults.standard.countApp.playerNames = $0.players
                            selectOldGameActive = false
                        }
                    }
                    
                    if let gameList = gameList {
                        NavigationLink("Start",
                                       destination: CountAppTableView()
                            .environmentObject(gameList)
                            .navigationTitle(gameList.name)
                            .navigationBarHidden(true)
                            .onDisappear {
                                do {
                                    try gameList.save()
                                } catch {
                                    print("error saving game \(gameList.name): \(error.localizedDescription)")
                                }
                            }
                        )
                        Text("Game: \(gameList.name)")
                    }
                    
                    if let exitClosure = exitClosure {
                        Button("Exit", action: exitClosure)
                    }
                    
                }
                .blur(radius: playerInputActive ? 5 : 0)
                .disabled(playerInputActive)
                
                if playerInputActive {
                    PlayerInputView { players in
                        self.playerList = players
                        self.gameList = TarotGameList(players: playerList)
                        playerInputActive = false
                    } cancel: {
                        playerInputActive = false
                    }
                    .background(Color.secondary.opacity(0.9))
                    .padding()
                    
                }
                
            }
            .navigationTitle("Player Setup")
            .navigationBarHidden(true)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    struct PlayerInputView: View {
        
        var action: ([String]) -> ()
        var cancel: () -> ()
        
        @State private var players: [String] = [String](repeating: "", count: TarotGame.playerRange.upperBound)
        
        var body: some View {
            VStack {
                HStack {
                    Spacer()
                    Button {
                        cancel()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                            .frame(width: 30, height: 30)
                    }
                    
                }
                VStack {
                    ForEach(0..<players.count, id: \.self) { i in
                        TextField("Name of player \(i + 1)", text: $players[i])
                            .playerNameBox(active: false)
                            .disableAutocorrection(true)
                            .textInputAutocapitalization(.words)
                            .padding(.horizontal)
                    }
                }
                Button("Done") {
                    let playerList = players.filter { !$0.isEmpty }
                    UserDefaults.standard.countApp.playerNames = players
                    action(playerList)
                }
                .padding()
                .buttonStyle(.bordered)
            }
            .onAppear {
                if let savedPlayers = UserDefaults.standard.countApp.playerNames {
                    players = savedPlayers
                    let missingPlaces = max(0, TarotGame.playerRange.upperBound - players.count)
                    players.append(contentsOf: [String](repeating: "", count: missingPlaces))
                }
            }
        }
        
    }
}

struct CountAppView_Previews: PreviewProvider {
    static var previews: some View {
        CountAppView()
    }
}
