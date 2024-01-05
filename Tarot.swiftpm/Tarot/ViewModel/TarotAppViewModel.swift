import Combine

class TarotAppViewModel: ObservableObject {

    enum State {
        case idle
        case creatingNewGame
        case playing(game: TarotGame)
    }
    @Published var state: State = .idle

    let gameManager = TarotGameManager_LocalFiles()

    func openGame(_ game: TarotGame) {
        self.state = .playing(game: game)
    }

    func closeGame() {
        self.state = .idle
    }

    func createNewGame() {
        self.state = .creatingNewGame
    }

}
