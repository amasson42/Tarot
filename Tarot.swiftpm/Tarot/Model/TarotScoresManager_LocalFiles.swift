import Foundation

class TarotGameManager_LocalFiles: TarotGameManagerProtocol {
    
    func getAllHeaders() -> [TarotGame.Header] {
        do {
            return try FileManager.default
                .contentsOfDirectory(at: Self.savingDirectory,
                                     includingPropertiesForKeys: nil)
                .compactMap { fileUrl in
                    try? TarotGame.Header(fromFile: fileUrl)
                }
                .sorted {
                    $0.date > $1.date
                }
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
//    
//#if DEBUG
//    private init(file: URL, name: String, date: Date, scores: [(String, Int)]) {
//        self.id = UUID()
//        (self.file, self.name, self.date, self.scores) = (file, name, date, scores)
//        self.color = .gray
//    }
//    
//    static let example0 = Self(file: URL(string: "/dev/null")!, name: "GaMeExAm", date: Date.now, scores: [("Gael", -20), ("Melany", 20), ("Exav", -10), ("Ambroise", 10)])
//    static let example1 = Self(file: URL(string: "/dev/null")!, name: "GaMeExAmPl", date: Date.now.advanced(by: 3600), scores: [("Gael", -200), ("Melany", 200), ("Exav", -150), ("Ambroise", 150), ("Pleb", 0)])
//    static let example2 = Self(file: URL(string: "/dev/null")!, name: "GaMeEx", date: Date.now.advanced(by: 86400), scores: [("Gael", -40), ("Melany", 30), ("Execve", 10)])
//#endif
//    
}


