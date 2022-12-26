import SwiftUI

/// Main feature of the Counting App feature
/// Needs a TarotGameList in environment to display its content and add new games to it
struct TarotTableView: View {
    
    @EnvironmentObject private var gameList: TarotGameList
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
                            ForEach(gameList.players.indices, id: \.self) { pi in
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
                        
                        TarotPlayerScoreTableView(gameList: gameList) {
                            showInputGame = true
                            inputGameIndex = $1
                        }
                    }
                }
                .background {
                    gameList.color
                        .onChange(of: gameList.color) { newValue in
                            print("on changed")
                        }
                }
                .cornerRadius(30)
                .overlay {
                    VStack {
                        Spacer()
                        HStack {
                            ColorPicker("", selection: $gameList.color)
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
                        gameList.addFausseDonne(forPlayer: distributor)
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
                        TarotAddGameView(gameList: gameList,
                                         game: gameList.gameHistory[gi].gameScore) { game in
                            gameList.gameHistory[gi].gameScore = game
                            gameList.updateCumulated()
                            showInputGame = false
                            inputGameIndex = nil
                            try? gameList.save()
                        } cancel: {
                            showInputGame = false
                            inputGameIndex = nil
                        }
                    } else {
                        TarotAddGameView(gameList: gameList) { game in
                            gameList.gameHistory.append((game, []))
                            gameList.updateCumulated()
                            showInputGame = false
                            inputGameIndex = nil
                            try? gameList.save()
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
    
    @ViewBuilder func DistributorIndicator() -> some View {
        ZStack {
            Image(systemName: "arrow.down")
                .foregroundColor(Color.indigo)
                .offset(x: 0, y: 10)
            Text("🃏")
                .rotationEffect(Angle(degrees: 15))
                .shadow(radius: 2)
                .offset(x: 5, y: 1)
            Text("🃏")
                .rotationEffect(Angle(degrees: 0))
                .shadow(radius: 2)
            Text("🃏")
                .rotationEffect(Angle(degrees: -15))
                .shadow(radius: 3)
                .offset(x: -5, y: 1)
                .rotation3DEffect(Angle(degrees: 20), axis: (0, 1, 0))
        }
    }
    
    func switchDistributor() {
        distributor = (distributor + 1) % gameList.players.count
    }
}

struct TarotTableView_Previews: PreviewProvider {
    
    static let names = ["Adrien", "Guillaume", "Arthur", "Nicolas", "Maman"]
    
    static var previews: some View {
        TarotTableView()
            .environmentObject(TarotGameList(players: names)!)
    }
}

