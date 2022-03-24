//
//  CountModels.swift
//  Tarot
//
//  Created by Giantwow on 27/12/2021.
//

import Combine
import SwiftUI

final class TarotGameList: ObservableObject {
    
    let players: [String]
    var createdDate: Date
    @Published var gameHistory: [TarotGameScore]
    @Published var scores: [Int]
    private var scoreUpdater: AnyCancellable?
    
    init?(players: [String]) {
        guard TarotGame.playerRange.contains(players.count) else {
            return nil
        }
        
        self.players = players
        self.createdDate = Date.now
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

extension TarotGameList: Codable {
    
    enum CodingKeys: String, CodingKey {
        case players
        case createdDate
        case gameHistory
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let players = try container.decode([String].self, forKey: .players)
        let createdDate = try container.decode(Date.self, forKey: .createdDate)
        let gameHistory = try container.decode([TarotGameScore].self, forKey: .gameHistory)
        self.init(players: players)!
        self.createdDate = createdDate
        self.gameHistory = gameHistory
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(players, forKey: .players)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(gameHistory, forKey: .gameHistory)
    }
    
    var savedName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy-MM-dd HH"
        let dateString = formatter.string(from: self.createdDate)
        
        let playersString = players.map { name in
            name[..<(name.index(name.startIndex, offsetBy: 2, limitedBy: name.endIndex) ?? name.endIndex)]
        }.reduce("", +)
        
        return "\(dateString)h \(playersString)"
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
    
    static func listGames() -> [String] {
        do {
            return try FileManager.default
                .contentsOfDirectory(at: savingDirectory,
                                     includingPropertiesForKeys: nil)
                .map { $0.lastPathComponent }
                .filter {
                    (try? loadGame(named: $0)) != nil
                }
        } catch {
            return []
        }
    }
    
    static func loadGame(named name: String) throws -> TarotGameList {
        let filePath = savingDirectory.appendingPathComponent(name).path
        guard let fileSize = try FileManager.default.attributesOfItem(atPath: filePath)[.size] as? Int,
              fileSize < 42000,
              let fileData = FileManager.default.contents(atPath: filePath) else {
            throw "File does not exists"
        }
        return try JSONDecoder().decode(TarotGameList.self, from: fileData)
    }
    
    func save() throws {
        try FileManager.default.createDirectory(at: Self.savingDirectory, withIntermediateDirectories: true)
        let fileUrl = Self.savingDirectory.appendingPathComponent(self.savedName)
        let saveData = try JSONEncoder().encode(self)
        try saveData.write(to: fileUrl)
    }
    
    static func deleteGame(named name: String) throws {
        let fileUrl = savingDirectory.appendingPathComponent(name)
        try FileManager.default.removeItem(at: fileUrl)
    }
    
    static func renameGame(from oldName: String, to newName: String) throws {
        let oldUrl = savingDirectory.appendingPathComponent(oldName)
        let newUrl = savingDirectory.appendingPathComponent(newName)
        try FileManager.default.moveItem(at: oldUrl, to: newUrl)
    }
    
}
