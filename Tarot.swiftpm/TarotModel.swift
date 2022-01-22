//
//  TarotModel.swift
//  Tarot
//
//  Created by Giantwow on 27/12/2021.
//

import Foundation

struct TarotGame {
    /// Min and Max number of players
    static let playerRange = 3...5
    
    private init() {}
}

enum TarotGameBet: String, CaseIterable, CustomStringConvertible {
    case fausseDonne = "Fausse Done"
    case petite = "Petite"
    case pouce = "Pouce"
    case garde = "Garde"
    case gardeSans = "Garde Sans"
    case gardeContre = "Garde Contre"
    
    var description: String { rawValue }
    
    var pointsFactor: Int {
        switch self {
        case .fausseDonne: return 1
        case .petite: return 1
        case .pouce: return 2
        case .garde: return 4
        case .gardeSans: return 8
        case .gardeContre: return 16
        }
    }
    
    static var bets: [TarotGameBet] {
        return [.petite, .pouce, .garde, .gardeSans, .gardeContre]
    }
}

enum TarotGameOverflow: UInt8, CaseIterable {
    case p0 = 0
    case p10 = 10
    case p20 = 20
    case p30 = 30
    //    case p40 = 40
    
    var value: Int { Int(rawValue) }
}

enum TarotGameSideGain: CaseIterable, CustomStringConvertible {
    case misery
    case doubleMisery
    case poignee
    case doublePoignee
    case petitAuBout
    case petitAuBouffe
    case bonus
    case malus
    
    var value: Int {
        switch self {
        case .misery: return 1
        case .doubleMisery: return 2
        case .poignee: return 1
        case .doublePoignee: return 2
        case .petitAuBout: return 1
        case .petitAuBouffe: return -1
        case .bonus: return 1
        case .malus: return -1
        }
    }
    
    var description: String {
        switch self {
        case .misery: return "misère"
        case .doubleMisery: return "double misère"
        case .poignee: return "poignée"
        case .doublePoignee: return "double poignée"
        case .petitAuBout: return "petit au bout"
        case .petitAuBouffe: return "petit perdu au bout"
        case .bonus: return "bonus"
        case .malus: return "malus"
        }
    }
}

struct TarotGameScore: Identifiable {
    struct SideGain: Equatable {
        let player: Int
        let gain: TarotGameSideGain
    }
    
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
    var sideGains: [SideGain] = []
    { didSet { updateScores() }}
    
    private(set) var scores: [Int] = []
    
    init(playerCount: Int,
         mainPlayer: Int = 0, secondPlayer: Int? = nil,
         won: Bool = true, overflow: TarotGameOverflow = .p0, bet: TarotGameBet = .petite,
         sideGains: [SideGain] = []) {
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
    
    func sideGain(forPlayer player: Int) -> [TarotGameSideGain] {
        self.sideGains
            .filter { $0.player == player }
            .map { $0.gain }
    }
    
}

extension TarotGameScore: CustomStringConvertible {
    
    func description(withPlayers players: [String]) -> String {
        assert(players.count == playerCount)
        
        let gameSetupWords = "Partie de \(playerCount) joueurs"
        
        let betWords = "\(players[mainPlayer]) \(won ? "gagne" : "perd") une \(bet.description.lowercased()) \(won ? "faite" : "chutée") de \(overflow.value)"
        
        let friendWord: String = {
            if let second = secondPlayer {
                return "avec \(players[second])"
            } else {
                return "seul"
            }
        }()
        
        let sideGainsWords = sideGains.reduce("") { r, pg in
            let gainWord: String
            switch pg.gain {
            case .misery: gainWord = "a une misère"
                case .doubleMisery: gainWord = "a une double misère"
            case .poignee: gainWord = "a une poignée"
            case .doublePoignee: gainWord = "a une double poignée"
            case .petitAuBout: gainWord = "a fait le dernier plie avec le petit"
            case .petitAuBouffe: gainWord = "se fait couper son petit au dernier tour"
            case .bonus: gainWord = "gagne un bonus"
            case .malus: gainWord = "prend une penalité"
            }
            return r + "\n\(players[pg.player]) \(gainWord)."
        }
        
        return "\(gameSetupWords), \(betWords) \(friendWord).\(sideGainsWords)"
    }
    
    var description: String {
        return description(withPlayers: (0..<playerCount).map { "j\($0 + 1)" })
    }
}
