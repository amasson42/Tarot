import Combine
import Foundation


protocol TarotGameManagerProtocol: AnyObject, ObservableObject {
    
    func getAllHeaders() async -> [TarotGame.Header]
    
    func load(header: TarotGame.Header) async throws -> TarotGame
    
    func save(game: TarotGame) async throws
    
    func delete(header: TarotGame.Header) async throws
    
}

class TarotGameManager_LocalFiles: TarotGameManagerProtocol {
    
    func getAllHeaders() -> [TarotGame.Header] {
        do {
            let headers = try FileManager.default
                .contentsOfDirectory(at: Self.savingDirectory,
                                     includingPropertiesForKeys: nil)
                .compactMap { fileUrl in
                    try? TarotGame.Header(fromFile: fileUrl)
                }
                .sorted {
                    $0.date > $1.date
                }
            return headers
        } catch {
            return []
        }
        
    }
    
    func load(header: TarotGame.Header) throws -> TarotGame {
        let data = try Data(contentsOf: header.file)
        return try JSONDecoder().decode(TarotGame.self, from: data)
    }
    
    func save(game: TarotGame) throws {
        let fileUrl = try createFileUrl(forGame: game)
        let saveData = try JSONEncoder().encode(game)
        try saveData.write(to: fileUrl)
    }
    
    func createFileUrl(forGame game: TarotGame) throws -> URL {
        try FileManager.default.createDirectory(at: Self.savingDirectory, withIntermediateDirectories: true)
        return Self.savingDirectory.appendingPathComponent("\(game.id)")
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
    
    func delete(header: TarotGame.Header) throws {
        try FileManager.default.removeItem(at: header.file)
    }

}


class TarotGameManager_Mock: TarotGameManagerProtocol {
    
    var games: [TarotGame] = [
        TarotGame(
            players: ["A", "B", "C"],
            name: "FirstGame",
            color: .red,
            createdDate: .now
        )!,
        TarotGame(
            players: ["A", "B", "C", "D"],
            name: "SecondGame",
            color: .red,
            createdDate: .now
        )!,
        TarotGame(
            players: ["A", "B", "C"],
            name: "ThirdGame",
            color: .red,
            createdDate: .now
        )!,
        
    ]
    
    func getAllHeaders() -> [TarotGame.Header] {
        [
            TarotGame.Header(),
            TarotGame.Header(),
            TarotGame.Header(),
        ]
    }
    
    func load(header: TarotGame.Header) throws -> TarotGame {
        TarotGame(
            players: header.scores.map { $0.playerName },
            id: header.id,
            name: header.name,
            color: header.color,
            createdDate: header.date
        )!
    }
    
    func save(game: TarotGame) throws {
        
    }
    
    func delete(header: TarotGame.Header) throws {
        
    }
    
}
