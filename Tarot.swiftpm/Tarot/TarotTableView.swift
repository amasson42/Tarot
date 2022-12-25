import SwiftUI

/// Main feature of the Counting App feature
/// Needs a TarotGameList in environment to display its content and add new games to it
struct TarotTableView: View {
    
    @EnvironmentObject private var gameList: TarotGameList
    
    @State private var showInputGame: Bool = false
    @State private var inputGameIndex: Int? = nil
    @State private var showFausseDonePanel: Bool = false
    
    var body: some View {
        
        ZStack {
            
            VStack {
                // Players table
                ScrollView {
                    TarotPlayerScoreTableView(gameList: gameList) {
                        showInputGame = true
                        inputGameIndex = $1
                    }
                }
                .background(Color.brown.opacity(0.7))
                
                // Add game button
                HStack {
                    Spacer()
                    
                    if showFausseDonePanel {
                        HStack(alignment: .top) {
                            VStack {
                                ForEach(gameList.players.indices, id: \.self) { index in
                                    Button("\(gameList.players[index])") {
                                        gameList.addFausseDonne(forPlayer: index)
                                        withAnimation {
                                            showFausseDonePanel = false
                                        }
                                    }
                                }
                            }
                            Button {
                                withAnimation {
                                    showFausseDonePanel = false
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(.red)
                            }
                        }
                        .border(.gray, width: 2)
                    } else {
                        Button("Fausse Done") {
                            withAnimation {
                                showFausseDonePanel = true
                            }
                        }
                        .tarotButton()
                    }
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
                        TarotAddGameView(gameList: gameList,
                                            game: gameList.gameHistory[gi]) { game in
                            gameList.gameHistory[gi] = game
                            showInputGame = false
                            inputGameIndex = nil
                            try? gameList.save()
                        } cancel: {
                            showInputGame = false
                            inputGameIndex = nil
                        }
                    } else {
                        TarotAddGameView(gameList: gameList) { game in
                            gameList.gameHistory.append(game)
                            showInputGame = false
                            inputGameIndex = nil
                            try? gameList.save()
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
}

struct TarotTableView_Previews: PreviewProvider {
    
    static let names = ["Adrien", "Guillaume", "Arthur", "Nicolas", "Maman"]
    
    static var previews: some View {
        TarotTableView()
            .environmentObject(TarotGameList(players: names)!)
    }
}
