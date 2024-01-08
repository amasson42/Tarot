import Combine

class TarotGameViewModel: ObservableObject {
    
    private var gameManager: any TarotGameManagerProtocol
    @Published var game: TarotGame
    
    @Published var distributor: Int = 0
    
    enum State: Equatable {
        case idle
        case creatingNewRound
        case modifyingRound(roundIndex: Int)
        case settingGame
    }
    @Published var state: State = .idle
    
    var isIdlingOnScoreboard: Bool {
        state == .idle
    }
    
    var isDisplayingRoundInputView: Bool {
        switch state {
        case .modifyingRound(_): true
        case .creatingNewRound: true
        default: false
        }
    }
    
    init(game: TarotGame, gameManager: any TarotGameManagerProtocol) {
        self.game = game
        self.gameManager = gameManager
    }
    
    func resetState() {
        self.state = .idle
    }
    
    func appendRound(round: TarotRound) {
        game.rounds.append((round, []))
        game.updateCumulated()
        self.state = .idle
        switchDistributor()
        self.saveGame()
    }
    
    func modifyRound(index: Int , round: TarotRound) {
        self.game.rounds[index].round = round
        self.game.updateCumulated()
        self.resetState()
        
        self.saveGame()
    }
    
    func removeRound(index: Int) {
        self.resetState()
        game.rounds.remove(at: index)
        
        self.saveGame()
    }
    
    func switchDistributor() {
        self.distributor = (self.distributor + 1) % self.game.players.count
    }
    
    func appendFausseDone() {
        self.game.addFausseDonne(forPlayer: self.distributor)
        self.switchDistributor()
    }
    
    func saveGame() {
        Task {
            try? await self.gameManager.save(game: self.game)
        }
    }
}
