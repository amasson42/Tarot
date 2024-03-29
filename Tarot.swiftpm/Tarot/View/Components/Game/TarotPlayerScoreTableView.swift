import SwiftUI

/// Reusable view from Counting App feature
/// Display the content of the TarotGame in parameter
struct TarotPlayerScoreTableView: View {
    
    @ObservedObject var game: TarotGame
    
    var cellAction: (Int, Int) -> ()
    
    private let layout: [GridItem]
    
    init(game: TarotGame, cellAction: @escaping (Int, Int) -> () = { _, _ in }) {
        self._game = .init(wrappedValue: game)
        self.cellAction = cellAction
        self.layout = [GridItem](repeating: GridItem(), count: game.players.count)
    }
    
    var body: some View {
        
        LazyVGrid(columns: layout, spacing: 0, pinnedViews: .sectionHeaders) {
            Section(header: HeaderSection) {
                
                ForEach(game.rounds.indices, id: \.self) { roundIndex in
                    ForEach(game.players.indices, id: \.self) { playerIndex in
                        
                        
                        Button {
                            cellAction(playerIndex, roundIndex)
                        } label: {
                            PlayerScoreView(
                                round: game.rounds[roundIndex].round,
                                cumulated: game.rounds[roundIndex].cumulated,
                                playerIndex: playerIndex)
                        }
                        .foregroundColor(.primary)
                        .id(game.players.count + roundIndex * game.players.count + playerIndex)
                        
                    }
                }
                
                ForEach(game.players.indices, id: \.self) { playerIndex in
                    VStack(alignment: .center) {
                        Text("\(game.finalScores[playerIndex].score)")
                            .fontWeight(.heavy)
                            .lineLimit(1)
                            .id(game.players.count + game.players.count * game.rounds.count + playerIndex)
                        
                        ClassmentView(classment: game.finalScores[playerIndex].classment)
                            .modifier(EnormeMerdeModifier(game: game, playerIndex: playerIndex))
                    }
                }
            }
        }
        .background {
            ZStack {
                self.game.color
                Color.brown.opacity(0.5)
            }
            .blur(radius: 1)
        }
        
    }
    
    struct EnormeMerdeModifier: ViewModifier {
        
        let scale: CGFloat
        
        init(game: TarotGame, playerIndex: Int) {
            if game.finalScores[playerIndex].classment == 5 {
                
                let playersAboveZero = game.finalScores.filter({ $0.score > 0 }).count
                let scalerIndexors: [Int: CGFloat] = [
                    0: 1,
                    1: 1,
                    2: 1.5,
                    3: 2,
                    4: 3
                ]
                
                let noobFactor = 1.0 + abs(CGFloat(game.finalScores[playerIndex].score)) * 0.002 * scalerIndexors[playersAboveZero, default: 1.0]
                
                self.scale = noobFactor
                
            } else {
                self.scale = 1.0
            }
        }
        
        func body(content: Content) -> some View {
            return Text(" ")
                .overlay {
                    content
                        .font(.custom("system", size: 20 * scale))
                        .frame(width: 200, height: 20)
                }
        }
        
    }
    
    @ViewBuilder var HeaderSection: some View {
        HStack {
            ForEach(game.players.indices, id: \.self) { playerIndex in
                Text(game.players[playerIndex])
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .id(playerIndex)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.bottom)
    }
    
    struct PlayerScoreView: View {
        
        let round: TarotRound
        let cumulated: [TarotGame.ScoreCumul]
        let playerIndex: Int
        
        var score: Int { round.score(forPlayer: playerIndex) }
        var wonColor: Color {
            Color([#colorLiteral(red: 0.5607469081878662, green: 0.9999999403953552, blue: 0.5676395297050476, alpha: 1.0), #colorLiteral(red: 1.0000003576278687, green: 0.4104778468608856, blue: 0.33868008852005005, alpha: 1.0)][round.won(forPlayer: playerIndex) ? 0 : 1])
        }
        
        var body: some View {
            
            ZStack {
                
                HStack(alignment: .center, spacing: 8) {
                    
                    Divider()
                    VStack(spacing: -10) {
                        
                        ZStack {
                            if playerIndex == round.mainPlayer {
                                TarotBetView(bet: round.bet)
                                    .frame(height: 30)
                                    .opacity(0.5)
                            }
                            
                            Text("\(score)")
                                .foregroundColor(wonColor)
                                .lineLimit(1)
                                .minimumScaleFactor(0.2)
                                .background(Color.black
                                    .clipShape(Capsule())
                                    .opacity(0.3)
                                    .blur(radius: 3))
                        }
                        
                        if !round.sideGain(forPlayer: playerIndex).isEmpty {
                            SideGainsView(sideGains: round.sideGain(forPlayer: playerIndex))
                        }
                        
                    }
                    .frame(maxWidth: .infinity)
                    
                    GameCumulView(gameCumul: cumulated[playerIndex])
                    
                    Divider()
                    
                }
                
            }
        }
        
        struct SideGainsView: View {
            let sideGains: [TarotSideGain]
            
            var body: some View {
                HStack(spacing: -4) {
                    ForEach(sideGains.indices, id: \.self) { i in
                        sideGains[i]
                            .frame(width: 15, height: 15)
                    }
                }
            }
        }
        
    }
    
    
}

#Preview {
    
    TarotPlayerScoreTableView(game: {
        let game = TarotGame(players: ["Arthur", "Guillaume", "Adrien", "Nicolas", "Maman"])!
        
        game.players.indices.forEach {
            game.addFausseDonne(forPlayer: $0)
        }
        
        game.addRound(bet: .petite, by: 2, calling: 3, won: true, overflow: .p10)
        
        game.addRound(bet: .garde, by: 1, calling: nil, won: true, overflow: .p30)
        
        game.rounds[6].round.attributedSideGains.append(.init(player: 1, gain: .doublePoignee))
        game.rounds[6].round.attributedSideGains.append(.init(player: 1, gain: .petitAuBout))
        game.rounds[6].round.attributedSideGains.append(.init(player: 1, gain: .misery))
        
        game.addFausseDonne(forPlayer: 0)

        game.addRound(bet: .garde, by: 4, calling: nil, won: false, overflow: .p20)

        return game
    }())
}

