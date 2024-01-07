import SwiftUI

/// Main feature of the Counting App feature
/// Needs a TarotGame in environment to display its content and add new games to it
struct TarotTableView: View {
    
    @ObservedObject var game: TarotGame

    @State var distributor: Int = 0
    @State private var showInputGame: Bool = false
    @State private var inputGameIndex: Int? = nil
    
    var body: some View {
        
        ZStack {
            
            VStack {
                // Players table
                
                ScrollView {
                    VStack {
                        Spacer(minLength: 10)
                        
                        HStack {
                            ForEach(game.players.indices, id: \.self) { pi in
                                if pi == distributor {
                                    DistributorIndicator()
                                } else {
                                    Spacer()
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .onTapGesture {
                            switchDistributor()
                        }
                        
                        TarotPlayerScoreTableView(game: game) {
                            showInputGame = true
                            inputGameIndex = $1
                        }
                    }
                }
                .background {
                    game.color
                        .onChange(of: game.color) { newValue in
                            print("on changed")
                        }
                }
                .cornerRadius(30)
                .overlay {
                    VStack {
                        Spacer()
                        HStack {
                            ColorPicker("", selection: $game.color)
                                .frame(width: 50, height: 50)
                            Spacer()
                        }
                        Spacer()
                            .frame(height: 10)
                    }
                }
                
                // Add game button
                HStack {
                    Spacer()
                    
                    Button("Fausse Done") {
                        game.addFausseDonne(forPlayer: distributor)
                        switchDistributor()
                    }
                    .tarotButton()
                    
                    Button("Add game") {
                        showInputGame = true
                    }
                    .tarotButton()
                    
                }
            }
            .padding()
            .disabled(showInputGame)
            .blur(radius: showInputGame ? 5 : 0)
            
            if showInputGame {
                
                Group {
                    if let gi = inputGameIndex {
                        TarotAddRoundView(
                            game: game,
                            round: game.rounds[gi].round
                        ) { round in
                            game.rounds[gi].round = round
                            game.updateCumulated()
                            showInputGame = false
                            inputGameIndex = nil
                            
                            try? TarotGameManager_LocalFiles().save(game: game)
                        } cancel: {
                            showInputGame = false
                            inputGameIndex = nil
                        } delete: {
                            showInputGame = false
                            inputGameIndex = nil
                            game.rounds.remove(at: gi)
                            try? TarotGameManager_LocalFiles().save(game: game)
                        }
                    } else {
                        TarotAddRoundView(game: game) { round in
                            game.rounds.append((round, []))
                            game.updateCumulated()
                            showInputGame = false
                            inputGameIndex = nil
                            try? TarotGameManager_LocalFiles().save(game: game)
                            switchDistributor()
                        } cancel: {
                            showInputGame = false
                            inputGameIndex = nil
                        }
                    }
                }
                .opacity(0.7)
                .padding()
                
            }
            
        }
        .background(GrassBackground().blur(radius: 1))
        
    }
    
    func switchDistributor() {
        distributor = (distributor + 1) % game.players.count
    }
}

#Preview {
    TarotTableView(game: TarotGame(players: ["Adrien", "Guillaume", "Arthur", "Nicolas", "Maman"])!)
}
