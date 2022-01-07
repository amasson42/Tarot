//
//  CountModels.swift
//  Tarot
//
//  Created by Giantwow on 27/12/2021.
//

import Combine
import SwiftUI

class TarotGameList: ObservableObject {
    
    let players: [String]
    @Published var gameHistory: [TarotGameScore]
    @Published var scores: [Int]
    private var scoreUpdater: AnyCancellable?
    
    init(players: [String]) {
        assert(TarotGame.playerRange.contains(players.count))
        
        self.players = players
        self.gameHistory = []
        self.scores = [Int](repeating: 0, count: players.count)
        
        self.scoreUpdater = self.$gameHistory.sink { [self] scores in
            self.scores = scores.reduce([Int](repeating: 0, count: self.players.count)) { total, game in
                total.enumerated().map {
                    $0.element + game.score(forPlayer: $0.offset)
                }
            }
        }
    }
    
    func addGame(bet: TarotGameBet, by player: Int, calling secondPlayer: Int? = nil, won: Bool, overflow: TarotGameOverflow) {
        let gameScore = TarotGameScore(
            playerCount: self.players.count,
            mainPlayer: player,
            secondPlayer: secondPlayer,
            won: won,
            overflow: overflow,
            bet: bet,
            sideGains: [])
        
        self.gameHistory.append(gameScore)
    }
    
    /// Create a fausse done for the target player
    func addFausseDonne(forPlayer player: Int) {
        let gameScore = TarotGameScore(
            playerCount: self.players.count,
            mainPlayer: player,
            secondPlayer: nil,
            won: false,
            overflow: .p0,
            bet: .fausseDonne,
            sideGains: [])
        
        self.gameHistory.append(gameScore)
    }
    
}
