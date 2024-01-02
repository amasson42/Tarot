import SwiftUI

/// Reusable view from Counting App feature
/// Display the content of the TarotGameList in parameter
struct TarotPlayerScoreTableView: View {
    
    @ObservedObject var gameList: TarotGameList
    
    var cellAction: (Int, Int) -> ()
    
    private let layout: [GridItem]
    
    init(gameList: TarotGameList, cellAction: @escaping (Int, Int) -> () = { _, _ in }) {
        self._gameList = .init(wrappedValue: gameList)
        self.cellAction = cellAction
        self.layout = [GridItem](repeating: GridItem(), count: gameList.players.count)
    }
    
    var body: some View {
        
        LazyVGrid(columns: layout, spacing: 0, pinnedViews: .sectionHeaders) {
            Section(header: header) {
                
                ForEach(gameList.gameHistory.indices, id: \.self) { gi in
                    ForEach(gameList.players.indices, id: \.self) { pi in
                        
                        
                        Button {
                            cellAction(pi, gi)
                        } label: {
                            PlayerScoreView(game: gameList.gameHistory[gi].gameScore, cumulated: gameList.gameHistory[gi].cumulated, pi: pi)
                        }
                        .foregroundColor(.primary)
                        .id(gameList.players.count + gi * gameList.players.count + pi)
                        
                    }
                }
                
                ForEach(gameList.players.indices, id: \.self) { pi in
                    VStack(alignment: .center) {
                        Text("\(gameList.finalScores[pi].score)")
                            .fontWeight(.heavy)
                            .lineLimit(1)
                            .id(gameList.players.count + gameList.players.count * gameList.gameHistory.count + pi)
                        
                        ClassmentView(classment: gameList.finalScores[pi].classment)
                            .modifier(EnormeMerdeModifier(gameList: gameList, playerIndex: pi))
                    }
                }
            }
        }
        
    }
    
    struct EnormeMerdeModifier: ViewModifier {
        
        let scale: CGFloat?
        
        init(gameList: TarotGameList, playerIndex: Int) {
            if gameList.finalScores[playerIndex].classment == 5 {
                
                let playersAboveZero = gameList.finalScores.filter({ $0.score > 0 }).count
                let scalerIndexors: [Int: CGFloat] = [
                    0: 1,
                    1: 1,
                    2: 1.5,
                    3: 2,
                    4: 3
                ]
                
                let noobFactor = 1.0 + abs(CGFloat(gameList.finalScores[playerIndex].score)) * 0.002 * scalerIndexors[playersAboveZero, default: 1.0]
                
                self.scale = noobFactor
                
            } else {
                self.scale = nil
            }
        }
        
        func body(content: Content) -> some View {
            return Text(" ")
                .overlay {
                    content
                        .font(.custom("system", size: 20 * (scale ?? 1.0 )))
                        .frame(width: 200, height: 20)
                }
        }
        
    }
    
    @ViewBuilder var header: some View {
        HStack {
            ForEach(gameList.players.indices, id: \.self) { pi in
                Text(gameList.players[pi])
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .id(pi)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.bottom)
    }
    
    struct PlayerScoreView: View {
        
        let game: TarotGame
        let cumulated: [TarotGameList.GameCumul]
        let pi: Int
        
        var score: Int { game.score(forPlayer: pi) }
        var wonColor: Color {
            Color([#colorLiteral(red: 0.5607469081878662, green: 0.9999999403953552, blue: 0.5676395297050476, alpha: 1.0), #colorLiteral(red: 1.0000003576278687, green: 0.4104778468608856, blue: 0.33868008852005005, alpha: 1.0)][game.won(forPlayer: pi) ? 0 : 1])
        }
        
        var body: some View {
            
            ZStack {
                
                HStack(alignment: .center, spacing: 8) {
                    
                    Divider()
                    VStack(spacing: -10) {
                        
                        ZStack {
                            if pi == game.mainPlayer {
                                game.bet.frame(height: 30)
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
                        
                        if !game.sideGain(forPlayer: pi).isEmpty {
                            SideGainView(sideGains: game.sideGain(forPlayer: pi))
                        }
                        
                    }
                    .frame(maxWidth: .infinity)
                    
                    GameCumulView(gameCumul: cumulated[pi])
                    
                    Divider()
                    
                }
                
            }
        }
        
        struct GameCumulView: View {
            var gameCumul: TarotGameList.GameCumul
            
            var body: some View {
                VStack {
                    Text("\(gameCumul.score)")
                        .bold()
                        .lineLimit(1)
                        .minimumScaleFactor(0.2)
                        .frame(maxWidth: .infinity)
                    
                    HStack(spacing: 0) {
                        
                        PositionChangerView(positionChanger: gameCumul.positionChanger)
                            .minimumScaleFactor(0.2)
                        
                        ClassmentView(classment: gameCumul.classment)
                        
                    }
                }
            }
            
            @ViewBuilder func PositionChangerView(positionChanger: TarotGameList.PositionChanger) -> some View {
                switch positionChanger {
                case .stay:
                    Text("-")
                        .foregroundColor(.gray)
                case .increase:
                    Text("↗")
                        .foregroundColor(.green)
                case .decrease:
                    Text("↘")
                        .foregroundColor(.red)
                }
            }
            
        }
        
        struct SideGainView: View {
            let sideGains: [TarotGameSideGain]
            
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
    
    struct ClassmentView: View {
        var classment: Int
        
        var body: some View {
            switch classment {
            case 1:
                Text("🥇")
            case 2:
                Text("🥈")
            case 3:
                Text("🥉")
            case 4:
                Text("💝")
            case 5:
                Text("💩")
            default:
                Text(" ")
            }
            
        }
    }
}

struct TarotPlayerScoreTableView_Previews: PreviewProvider {
    
    static let listExample0: TarotGameList = {
        let gameList = TarotGameList(players: ["Arthur", "Guillaume", "Adrien", "Nicolas", "Maman"])!
        
        gameList.players.indices.forEach {
            gameList.addFausseDonne(forPlayer: $0)
        }
        
        gameList.addGame(bet: .petite, by: 2, calling: 3, won: true, overflow: .p10)
        
        gameList.addGame(bet: .garde, by: 1, calling: nil, won: true, overflow: .p30)
        
        gameList.gameHistory[6].gameScore.sideGains.append(.init(player: 1, gain: .doublePoignee))
        gameList.gameHistory[6].gameScore.sideGains.append(.init(player: 1, gain: .petitAuBout))
        gameList.gameHistory[6].gameScore.sideGains.append(.init(player: 1, gain: .misery))
        
        gameList.addFausseDonne(forPlayer: 0)
        //        gameList.addGame(bet: .garde, by: 4, calling: nil, won: false, overflow: .p20)
        return gameList
    }()
    
    static var previews: some View {
        TarotPlayerScoreTableView(gameList: listExample0)
    }
}
