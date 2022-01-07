//
//  TarotModel.swift
//  Tarot
//
//  Created by Giantwow on 27/12/2021.
//

import Foundation

struct TarotGame {
    /// Min and Max number of players
    static let playerRange = 3..<5
    
    private init() {}
}

enum TarotGameBet: CustomStringConvertible {
    case fausseDonne
    case petite
    case pouce
    case garde
    case gardeSans
    case gardeContre
    
    var description: String {
        switch self {
        case .fausseDonne:
            return "Fausse Done"
        case .petite:
            return "Petite"
        case .pouce:
            return "Pouce"
        case .garde:
            return "Garde"
        case .gardeSans:
            return "Garde Sans"
        case .gardeContre:
            return "Garde Contre"
        }
    }
    
    var pointsFactor: Int {
        switch self {
        case .fausseDonne: return 1
        case .petite: return 1
        case .pouce: return 2
        case .garde: return 3
        case .gardeSans: return 4
        case .gardeContre: return 5
        }
    }
}

enum TarotGameOverflow: UInt8 {
    case p0 = 0
    case p10 = 10
    case p20 = 20
    case p30 = 30
    case p40 = 40
    
    var value: Int { Int(rawValue) }
}

enum TarotGameSideGain {
    case misery
    case poignee
    case doublePoignee
    case petitAuBout
    case petitAuBouffe
    case other
    
    var value: Int {
        switch self {
        case .misery: return 1
        case .poignee: return 1
        case .doublePoignee: return 2
        case .petitAuBout: return 1
        case .petitAuBouffe: return -1
        case .other: return 1
        }
    }
}

struct TarotGameScore: Identifiable {
    /// Identifiable UUID
    let id = UUID()
    
    /// Number of players in the game
    let playerCount: Int
    /// Index of player making the bet
    var mainPlayer: Int = 0
    { didSet { updateScores() }}
    /// Index of player called in the bet
    var secondPlayer: Int? = nil
    { didSet { updateScores() }}
    
    /// Did the main player won
    var won: Bool = true
    { didSet { updateScores() }}
    /// How much of overflow ? (0, 10, 20, 30 ?)
    var overflow: TarotGameOverflow = .p0
    { didSet { updateScores() }}
    /// Type of bet
    var bet: TarotGameBet = .petite
    { didSet { updateScores() }}
    /// Side gains
    var sideGains: [(player: Int, gain: TarotGameSideGain)] = []
    { didSet { updateScores() }}
    
    private(set) var scores: [Int] = []
    
    init(playerCount: Int,
         mainPlayer: Int = 0, secondPlayer: Int? = nil,
         won: Bool = true, overflow: TarotGameOverflow = .p0, bet: TarotGameBet = .petite,
         sideGains: [(player: Int, gain: TarotGameSideGain)] = []) {
        assert(TarotGame.playerRange.contains(playerCount), "Invalid player count")
        assert(mainPlayer < playerCount)
        if let secondPlayer = secondPlayer {
            assert(secondPlayer < playerCount)
            assert(secondPlayer != mainPlayer)
        }
        self.playerCount = playerCount
        self.mainPlayer = mainPlayer
        self.secondPlayer = secondPlayer
        self.won = won
        self.overflow = overflow
        self.bet = bet
        self.sideGains = sideGains
        self.scores = self.calculateScores()
        assert(self.scores.reduce(0, +) == 0)
        assert(self.scores.count == self.playerCount)
    }
    
    mutating func updateScores() {
        self.scores = self.calculateScores()
    }
    
    func calculateScores() -> [Int] {
        
        /// The amount of points put in the game by the defending players individually
        let betPoints = bet.pointsFactor * 10 + overflow.value
        
        /// Final scores
        var scores = [Int](repeating: betPoints, count: playerCount)
        
        scores[mainPlayer] = 0
        if let sp = secondPlayer {
            scores[sp] = 0
        }
        // -> here the `scores` contains the values of the defending player in case of their success
        
        /// Total points of the defending team 
        let opposingPoints = scores.reduce(0, +)
        
        if let sp = secondPlayer {
            let tierPoints = opposingPoints / 3
            scores[mainPlayer] = -tierPoints * 2
            scores[sp] = -tierPoints
        } else {
            scores[mainPlayer] = -opposingPoints
        }
        // -> here the `scores` has a total of zero
        
        // if the game is won by attacking player, then we revert the score value for everyone
        if won {
            for i in scores.indices {
                scores[i] = -scores[i]
            }
        }
        
        // all gains have a factor value. Every other players will lose this value and the gained player will recieve the total of those scores
        sideGains.forEach { sideGain in
            for i in scores.indices {
                let points = sideGain.gain.value * 10
                if i == sideGain.player {
                    scores[i] += points * (playerCount - 1)
                } else {
                    scores[i] -= points 
                }
            }
        }
        
        return scores
    }
    
    func score(forPlayer player: Int) -> Int {
        scores[player]
    }
    
}
