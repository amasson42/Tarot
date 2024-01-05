import SwiftUI

struct TarotAppGameView: View {
    
    @ObservedObject var game: TarotGame

    @EnvironmentObject private var viewModel: TarotAppViewModel

    @State var distributor: Int = 0
    @State private var showInputGame: Bool = false
    @State private var inputGameIndex: Int? = nil

    private var gameManager: some TarotGameManagerProtocol {
        self.viewModel.gameManager
    }

    var body: some View {
        
        ZStack {
            
            VStack {
                // Players table
                
                ScrollView {
                    VStack {
                        Spacer(minLength: 10)
                        
                        HStack {
                            ForEach(self.game.players.indices, id: \.self) { pi in
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
                        
                        TarotPlayerScoreTableView(game: self.game) {
                            cellColumn, cellRow in
                            showInputGame = true
                            inputGameIndex = cellRow
                        }
                    }
                }
                .background {
                    self.game.color
                        .onChange(of: self.game.color) { newValue in
                            print("on changed")
                        }
                }
                .cornerRadius(30)
                .overlay {
                    VStack {
                        Spacer()
                        HStack {
                            ColorPicker("", selection: self.$game.color)
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
                        self.game.addFausseDonne(forPlayer: self.distributor)
                        self.switchDistributor()
                    }
                    .tarotButton()
                    
                    Button("Add game") {
                        self.showInputGame = true
                    }
                    .tarotButton()
                    
                }
            }
            .padding()
            .disabled(self.showInputGame)
            .blur(radius: self.showInputGame ? 5 : 0)
            
            if self.showInputGame {
                
                Group {
                    if let gi = self.inputGameIndex {
                        TarotAddRoundView(
                            game: game,
                            round: game.rounds[gi].round
                        ) { round in
                            game.rounds[gi].round = round
                            game.updateCumulated()
                            showInputGame = false
                            inputGameIndex = nil
                            
                            Task {
                                try? await self.gameManager.save(game: game)
                            }
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
        self.distributor = (self.distributor + 1) % self.game.players.count
    }
    
}

#Preview {
    TarotAppGameView(game: TarotGame(players: ["Arthur", "Guillaume", "Adrien"])!)
        .environmentObject(TarotAppViewModel())
}
