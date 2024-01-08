import SwiftUI

struct TarotAppRootView: View {
    
    @StateObject private var appViewModel: TarotAppViewModel = TarotAppViewModel()
    
    var body: some View {
        ZStack {
            switch self.appViewModel.state {
            case .idle:
                IdleView()
            case .creatingNewGame:
                CreatingGameView()
            case .playing(let game):
                PlayingView(game: game)
            }
            
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    NavbarToggleButton()
                        .padding()
                }
            }
        }
        .environmentObject(self.appViewModel)
    }
    
    @ViewBuilder
    func IdleView() -> some View {
        VStack {
            
            TarotGamePickerView(gameManager: self.appViewModel.gameManager) { game in
                self.appViewModel.openGame(game)
            }
            .padding()
            
            Button {
                self.appViewModel.createNewGame()
            } label: {
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 90, height: 90)
                    .tarotButton()
            }
            .padding()
        }
    }
    
    @ViewBuilder
    func CreatingGameView() -> some View {
        TarotGameCreationView { createdGame in
            self.appViewModel.openGame(createdGame)
        }
    }
    
    @ViewBuilder
    func PlayingView(game: TarotGame) -> some View {
        TarotAppGameView(game: game)
            .environmentObject(TarotGameViewModel(game: game, gameManager: self.appViewModel.gameManager))
    }
    
}

#Preview {
    TarotAppRootView()
}
