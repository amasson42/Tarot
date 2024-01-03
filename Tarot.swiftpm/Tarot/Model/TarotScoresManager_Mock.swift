
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
            name: "FirstGame",
            color: .red,
            createdDate: .now
        )!,
        TarotGame(
            players: ["A", "B", "C"],
            name: "FirstGame",
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
