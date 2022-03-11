//
//  CountAppTableView.swift
//  Tarot
//
//  Created by Giantwow on 27/12/2021.
//

import SwiftUI

/// Reusable view from Counting App feature
/// Display the content of the TarotGameList in parameter
struct CountAppPlayerScoreTable: View {
    
    @ObservedObject var gameList: TarotGameList
    
    var cellAction: (Int, Int) -> ()
    
    private let layout: [GridItem]
    
    init(gameList: TarotGameList, cellAction: @escaping (Int, Int) -> () = { _, _ in }) {
        self._gameList = .init(wrappedValue: gameList)
        self.cellAction = cellAction
        self.layout = [GridItem](repeating: GridItem(), count: gameList.players.count)
    }
    
    var body: some View {
        
        LazyVGrid(columns: layout, spacing: 0) {
            ForEach(gameList.players.indices) { pi in
//                ScrollView(.horizontal) {
                    Text(gameList.players[pi])
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
//                }
            }
            
            ForEach(gameList.gameHistory.indices, id: \.self) { gi in
                ForEach(gameList.players.indices) { pi in
                    
                    Button {
                        cellAction(pi, gi)
                    } label: {
                        PlayerScoreView(game: gameList.gameHistory[gi], pi: pi)
                    }
                    .foregroundColor(.primary)
                    
                }
            }
            
            ForEach(gameList.players.indices) { pi in
                Text("\(gameList.scores[pi])")
                    .fontWeight(.heavy)
                    .lineLimit(1)
            }
        }
        
    }
    
    struct PlayerScoreView: View {
        
        let game: TarotGameScore
        let pi: Int
        
        var score: Int {
            game.score(forPlayer: pi)
        }
        
        var body: some View {
            
            ZStack {
                
                VStack(spacing: -10) {
                    
                    if pi == game.mainPlayer {
                        ZStack {
                            game.bet.frame(height: 30)
                                .opacity(0.5)
                            Text("\(score)")
                                .lineLimit(1)
                                .background(Color.black
                                                .clipShape(Capsule())
                                                .opacity(0.3)
                                                .blur(radius: 3))
                        }
                    } else {
                        Text("\(score)")
                            .lineLimit(1)
                    }
                    
                    if !game.sideGain(forPlayer: pi).isEmpty {
                        SideGainView(sideGains: game.sideGain(forPlayer: pi))
                    }
                    
                }
                
            }
        }
        
        struct SideGainView: View {
            let sideGains: [TarotGameSideGain]
            
            var body: some View {
                HStack(spacing: -4) {
                    ForEach(sideGains.indices) { i in
                        sideGains[i]
                            .frame(width: 15, height: 15)
                    }
                }
            }
        }
        
    }
}

struct CountAppPlayerScoreTable_Previews: PreviewProvider {
    
    static let listExample0: TarotGameList = {
        let gameList = TarotGameList(players: ["Arthur", "Guillaume", "Adrien", "Nicolas", "Maman"])!
        
        gameList.players.indices.forEach {
            gameList.addFausseDonne(forPlayer: $0)
        }
        
        gameList.addGame(bet: .petite, by: 2, calling: 3, won: true, overflow: .p10)
        
        gameList.addGame(bet: .garde, by: 1, calling: nil, won: true, overflow: .p30)
        
        gameList.gameHistory[6].sideGains.append(.init(player: 1, gain: .doublePoignee))
        gameList.gameHistory[6].sideGains.append(.init(player: 1, gain: .petitAuBout))
        gameList.gameHistory[6].sideGains.append(.init(player: 1, gain: .misery))
        
        return gameList
    }()
    
    static var previews: some View {
        CountAppPlayerScoreTable(gameList: listExample0)
    }
}
