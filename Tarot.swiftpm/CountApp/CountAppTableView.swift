import SwiftUI

/// Main feature of the Counting App feature
/// Needs a TarotGameList in environment to display its content and add new games to it
struct CountAppTableView: View {
    
    @EnvironmentObject private var gameList: TarotGameList
    
    @State private var showInputGame: Bool = false
    @State private var inputGameIndex: Int? = nil
    
    var body: some View {
        
        ZStack {
            
            VStack {
                // Players table
                ScrollView {
                    CountAppPlayerScoreTable(gameList: gameList) {
                        showInputGame = true
                        inputGameIndex = $1
                    }
                }
                .background(Color.brown.opacity(0.7))
                
                // Add game button
                HStack {
                    Spacer()
                    Button("Add game") {
                        showInputGame = true
                    }
                    .padding()
                }
            }
            .padding()
            .disabled(showInputGame)
            .blur(radius: showInputGame ? 5 : 0)
            
            if showInputGame {
                
                Group {
                    if let gi = inputGameIndex {
                        CountAppAddGameView(gameList: gameList,
                                            game: gameList.gameHistory[gi]) { game in
                            gameList.gameHistory[gi] = game
                            showInputGame = false
                            inputGameIndex = nil
                        } cancel: {
                            showInputGame = false
                            inputGameIndex = nil
                        }
                    } else {
                        CountAppAddGameView(gameList: gameList) { game in
                            gameList.gameHistory.append(game)
                            showInputGame = false
                            inputGameIndex = nil
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

struct CountAppTableView_Previews: PreviewProvider {
    
    static let names = ["Adrien", "Guillaume", "Arthur", "Nicolas", "Maman"]
    
    static var previews: some View {
        CountAppTableView()
            .environmentObject(TarotGameList(players: names)!)
    }
}

