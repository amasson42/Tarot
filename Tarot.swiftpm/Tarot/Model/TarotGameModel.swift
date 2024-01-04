import Combine
import Foundation
import SwiftUI

final class TarotGame: ObservableObject, Identifiable {
    
    let id: UUID
    @Published var players: [String]
    @Published var name: String
    @Published var color: Color
    let createdDate: Date
    @Published var rounds: [(round: TarotRound, cumulated: [ScoreCumul])]
    
    struct ScoreCumul {
        var score: Int = 0
        var classment: Int = 1
        var positionChanger: PositionChanger = .stay
    }
    
    enum PositionChanger {
        case decrease
        case stay
        case increase
    }
    
    var finalScores: [ScoreCumul] {
        rounds.last?.cumulated ?? [ScoreCumul](repeating: ScoreCumul(score: 0, classment: 1, positionChanger: .stay), count: players.count)
    }
    
    init?(players: [String], id: UUID? = nil, name: String? = nil, color: Color? = nil, createdDate: Date? = nil) {
        guard TarotRound.playerRange.contains(players.count) else {
            return nil
        }
        
        self.id = id ?? UUID()
        self.players = players
        self.createdDate = createdDate ?? Date.now
        self.rounds = []
        
        self.name = name ?? players.map { name in
            name.firstLetters(n: 2)
        }.reduce("", +)
        
        self.color = color ?? .gray
        
    }
    
    func addRound(bet: TarotBet, by player: Int, calling secondPlayer: Int? = nil, won: Bool, overflow: TarotRoundOverflow) {
        let round = TarotRound(
            playerCount: self.players.count,
            mainPlayer: player,
            secondPlayer: secondPlayer,
            won: won,
            overflow: overflow,
            bet: bet)
        
        self.rounds.append((round, []))
        self.updateCumulated()
    }
    
    /// Create a fausse done for the target player
    func addFausseDonne(forPlayer player: Int) {
        let gameScore = TarotRound(
            playerCount: self.players.count,
            mainPlayer: player,
            won: false,
            bet: .fausseDonne)
        
        self.rounds.append((gameScore, []))
        self.updateCumulated()
    }
    
    func updateCumulated() {
        
        var scoreCumul: [ScoreCumul] = .init(repeating: ScoreCumul(), count: players.count)
        
        for (i, round) in rounds.enumerated() {
            
            let newScores = zip(scoreCumul.map(\.score), round.round.scores).map(+)
            
            let newClassments = scoresToClassment(scores: newScores)
            
            let newPositionChanger: [PositionChanger]
            if i == 0 {
                newPositionChanger = .init(repeating: .stay, count: players.count)
            } else {
                newPositionChanger = positionChangersFromClassments(oldClassment: scoreCumul.map(\.classment), newClassment: newClassments)
            }
            
            scoreCumul = zip(newScores, zip(newClassments, newPositionChanger)).map { (score, classNPos) in
                let (classment, positionChanger) = classNPos
                return ScoreCumul(score: score, classment: classment, positionChanger: positionChanger)
            }
            
            rounds[i].cumulated = scoreCumul
        }
    }
    
    private func scoresToClassment(scores: [Int]) -> [Int] {
        let sorted = scores.sorted()
        return scores.map {
            scores.count - (sorted.lastIndex(of: $0) ?? 1)
        }
    }
    
    private func positionChangersFromClassments(oldClassment: [Int], newClassment: [Int]) -> [PositionChanger] {
        zip(oldClassment, newClassment).map { old, new in
            if old > new {
                return .increase
            } else if old < new {
                return .decrease
            } else {
                return .stay
            }
        }
    }
    
}

extension TarotGame: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case players
        case name
        case color
        case createdDate
        case rounds
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let players = try container.decode([String].self, forKey: .players)
        let name = try container.decode(String.self, forKey: .name)
        let color = (try? container.decode(Color.self, forKey: .color)) ?? .gray
        let createdDate = try container.decode(Date.self, forKey: .createdDate)
        let rounds = try container.decode([TarotRound].self, forKey: .rounds)
        
        guard TarotRound.playerRange.contains(players.count) else {
            throw "Incorrect number of players"
        }
        self.init(players: players, id: id, name: name, color: color, createdDate: createdDate)!
        self.rounds = rounds.map { ($0, []) }
        self.updateCumulated()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(players, forKey: .players)
        try container.encode(name, forKey: .name)
        try container.encode(color, forKey: .color)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(rounds.map { $0.round }, forKey: .rounds)
    }
    
    /// A light version of the game list. load less data than the full game
    class Header: Identifiable {
        let file: URL
        let id: UUID
        let name: String
        let color: Color
        let date: Date
        let scores: [(playerName: String, score: Int)]
        
        init(fromFile file: URL) throws {
            self.file = file
            guard let fileSize = try FileManager.default.attributesOfItem(atPath: file.path)[.size] as? Int,
                  fileSize < 42000,
                  let fileData = FileManager.default.contents(atPath: file.path) else {
                throw "File \(file) is too big"
            }
            let game = try JSONDecoder().decode(TarotGame.self, from: fileData)
            
            self.id = game.id
            self.name = game.name
            self.color = game.color
            self.date = game.createdDate
            
            game.updateCumulated()
            
            self.scores = zip(game.players, game.finalScores.map(\.score)).map {
                $0
            }
        }
        
        init(file: URL = URL(string: "/dev/null")!,
             id: UUID = UUID(),
             name: String = "AnotherGame",
             color: Color = .gray,
             date: Date = .now,
             scores: [(String, Int)] = [("A", 0), ("B", 0), ("C", 0)]
        ) {
            self.file = file
            self.id = id
            self.name = name
            self.color = color
            self.date = date
            self.scores = scores
        }
        
    }
    
}
