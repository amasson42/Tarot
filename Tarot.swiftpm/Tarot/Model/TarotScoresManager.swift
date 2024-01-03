import Combine

protocol TarotGameManagerProtocol: AnyObject, ObservableObject {
    
    func getAllHeaders() -> [TarotGame.Header]
    
    func load(header: TarotGame.Header) throws -> TarotGame
    
    func save(game: TarotGame) throws
    
    func delete(header: TarotGame.Header) throws
    
}
