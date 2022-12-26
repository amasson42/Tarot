import Combine
import Foundation
import SwiftUI

final class TarotGameList: ObservableObject, Identifiable {
    
    let id: UUID
    @Published var players: [String]
    @Published var name: String
    @Published var color: Color
    let createdDate: Date
    @Published var gameHistory: [(gameScore: TarotGameScore, cumulated: [GameCumul])]
    
    struct GameCumul {
        var score: Int = 0
        var classment: Int = 1
        var positionChanger: PositionChanger = .stay
    }
    
    enum PositionChanger {
        case decrease
        case stay
        case increase
    }
    
    var finalScores: [GameCumul] {
        gameHistory.last?.cumulated ?? [GameCumul](repeating: GameCumul(score: 0, classment: 1, positionChanger: .stay), count: players.count)
    }
    
    init?(players: [String], id: UUID? = nil, name: String? = nil, color: Color? = nil, createdDate: Date? = nil) {
        guard TarotGame.playerRange.contains(players.count) else {
            return nil
        }
        
        self.id = id ?? UUID()
        self.players = players
        self.createdDate = createdDate ?? Date.now
        self.gameHistory = []
        
        self.name = name ?? players.map { name in
            name.firstLetters(n: 2)
        }.reduce("", +)
        
        self.color = color ?? .gray
        
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
        
        self.gameHistory.append((gameScore, []))
        self.updateCumulated()
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
        
        self.gameHistory.append((gameScore, []))
        self.updateCumulated()
    }
    
    func updateCumulated() {
        
        var gameCumul: [GameCumul] = .init(repeating: GameCumul(), count: players.count)
        
        for (i, game) in gameHistory.enumerated() {
            let newScores = zip(gameCumul.map(\.score), game.gameScore.scores).map(+)
            
            let newClassments = scoresToClassment(scores: newScores)
            
            let newPositionChanger: [PositionChanger]
            if i == 0 {
                newPositionChanger = .init(repeating: .stay, count: players.count)
            } else {
                newPositionChanger = positionChangersFromClassments(oldClassment: gameCumul.map(\.classment), newClassment: newClassments)
            }
            
            gameCumul = zip(newScores, zip(newClassments, newPositionChanger)).map { (score, classNPos) in
                let (classment, positionChanger) = classNPos
                return GameCumul(score: score, classment: classment, positionChanger: positionChanger)
            }
            
            gameHistory[i].cumulated = gameCumul
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

extension TarotGameList: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case players
        case name
        case color
        case createdDate
        case gameHistory
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let players = try container.decode([String].self, forKey: .players)
        let name = try container.decode(String.self, forKey: .name)
        let color = (try? container.decode(Color.self, forKey: .color)) ?? .gray
        let createdDate = try container.decode(Date.self, forKey: .createdDate)
        let gameHistory = try container.decode([TarotGameScore].self, forKey: .gameHistory)
        
        guard TarotGame.playerRange.contains(players.count) else {
            throw "Incorrect number of players"
        }
        self.init(players: players, id: id, name: name, color: color, createdDate: createdDate)!
        self.gameHistory = gameHistory.map { ($0, []) }
        self.updateCumulated()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(players, forKey: .players)
        try container.encode(name, forKey: .name)
        try container.encode(color, forKey: .color)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(gameHistory.map { $0.gameScore }, forKey: .gameHistory)
    }
    
    static let savingDirectory: URL = {
        let searchingPaths: [(FileManager.SearchPathDirectory, FileManager.SearchPathDomainMask)] = [
            (.documentDirectory, .userDomainMask),
            (.desktopDirectory, .userDomainMask),
            (.documentDirectory, .allDomainsMask),
        ]
        let directory = searchingPaths.compactMap {
            FileManager.default.urls(for: $0.0, in: $0.1).first
        }.first ?? FileManager.default.temporaryDirectory
        
        let gamesDir = directory
            .appendingPathComponent("Tarot")
            .appendingPathComponent("CountGames")
        
        return gamesDir
    }()
    
    func save() throws {
        try FileManager.default.createDirectory(at: Self.savingDirectory, withIntermediateDirectories: true)
        let fileUrl = Self.savingDirectory.appendingPathComponent("\(self.id)")
        let saveData = try JSONEncoder().encode(self)
        try saveData.write(to: fileUrl)
    }
    
    /// A light version of the game list. load less data than the full gamelist
    struct Header: Identifiable {
        let file: URL
        let id: UUID
        let name: String
        let color: Color
        let date: Date
        let scores: [(playerName: String, score: Int)]
        
        fileprivate init(file: URL) throws {
            self.file = file
            guard let fileSize = try FileManager.default.attributesOfItem(atPath: file.path)[.size] as? Int,
                  fileSize < 42000,
                  let fileData = FileManager.default.contents(atPath: file.path) else {
                throw "File \(file) is too big"
            }
            let gameList = try JSONDecoder().decode(TarotGameList.self, from: fileData)
            
            self.id = gameList.id
            self.name = gameList.name
            self.color = gameList.color
            self.date = gameList.createdDate
            
            gameList.updateCumulated()
            
            self.scores = zip(gameList.players, gameList.finalScores.map(\.score)).map {
                $0
            }
        }
        
        func load() throws -> TarotGameList {
            let data = try Data(contentsOf: self.file)
            return try JSONDecoder().decode(TarotGameList.self, from: data)
        }
        
        func delete() throws {
            try FileManager.default.removeItem(at: self.file)
        }
        
        #if DEBUG
        private init(file: URL, name: String, date: Date, scores: [(String, Int)]) {
            self.id = UUID()
            (self.file, self.name, self.date, self.scores) = (file, name, date, scores)
        }
        
        static let example0 = Self(file: URL(string: "/dev/null")!, name: "GaMeExAm", color: .red, date: Date.now, scores: [("Gael", -20), ("Melany", 20), ("Exav", -10), ("Ambroise", 10)])
        static let example1 = Self(file: URL(string: "/dev/null")!, name: "GaMeExAmPl", color: .blue, date: Date.now.advanced(by: 3600), scores: [("Gael", -200), ("Melany", 200), ("Exav", -150), ("Ambroise", 150), ("Pleb", 0)])
        static let example2 = Self(file: URL(string: "/dev/null")!, name: "GaMeEx", color: .green, date: Date.now.advanced(by: 86400), scores: [("Gael", -40), ("Melany", 30), ("Execve", 10)])
        #endif
        
    }
    
    static func listGames() -> [Header] {
        do {
            return try FileManager.default
                .contentsOfDirectory(at: savingDirectory,
                                     includingPropertiesForKeys: nil)
                .compactMap { fileUrl in
                    try? Header(file: fileUrl)
                }
                .sorted {
                    $0.date > $1.date
                }
        } catch {
            return []
        }
    }
    
}
