import SwiftUI

struct TarotAppRootView: View {
    
    @StateObject private var viewModel: TarotAppViewModel = TarotAppViewModel()
    
    var body: some View {
        ZStack {
            switch self.viewModel.state {
            case .idle:
                idleView()
            case .creatingNewGame:
                creatingGameView()
            case .playing(let game):
                playingView(game: game)
            }
        }
        .environmentObject(self.viewModel)
    }
    
    @ViewBuilder
    func idleView() -> some View {
        VStack {
            ScrollView {
                TarotGamePickerView(gameManager: self.viewModel.gameManager) { game in
                    self.viewModel.openGame(game)
                }
            }
        }
        
        Button {
            self.viewModel.createNewGame()
        } label: {
            Image(systemName: "plus.square.fill")
        }
    }
    
    @ViewBuilder
    func creatingGameView() -> some View {
        TarotGameCreationView { createdGame in
            self.viewModel.openGame(createdGame)
        }
    }
    
    @ViewBuilder
    func playingView(game: TarotGame) -> some View {
        TarotAppGameView(game: game)
    }
    
}

#Preview {
    TarotAppRootView()
}
