import SwiftUI

struct TarotAppGameView: View {
    
    @ObservedObject var game: TarotGame
    
    @EnvironmentObject private var gameViewModel: TarotGameViewModel
    
    var body: some View {
        
        ZStack {
            
            VStack {
                
                PlayersHeader()
                
                PlayersScoreTable()
                
                FooterButtons()
            }
            .padding()
            .disabled(!self.gameViewModel.isIdlingOnScoreboard)
            .blur(radius: self.gameViewModel.isIdlingOnScoreboard ? 0 : 5)
            
            if self.gameViewModel.isDisplayingRoundInputView {
                InputRoundView()
            }
            
        }
        .background(Background())
        
    }
    
    // MARK: PlayersHeader
    @ViewBuilder func PlayersHeader() -> some View {
        HStack {
            ForEach(self.game.players.indices, id: \.self) { playerIndex in
                if playerIndex == self.gameViewModel.distributor {
                    DistributorIndicator()
                } else {
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
        }
        .background {
            RoundedRectangle(cornerRadius: 10.0)
                .fill(Color.brown)
                .shadow(color: .black, radius: 10, x: 2, y: 3)
        }
        .background(Color(white: 0.0, opacity: 0.01))
        .onTapGesture {
            self.gameViewModel.switchDistributor()
        }
    }
    
    // MARK: PlayersScoreTable
    @ViewBuilder func PlayersScoreTable() -> some View {
        VStack {
            
            ScrollView {
                VStack {
                    
                    TarotPlayerScoreTableView(game: self.game) {
                        playerIndex, roundIndex in
                        self.gameViewModel.state = .modifyingRound(roundIndex: roundIndex)
                    }
                }
            }
            .cornerRadius(20)
            .padding([.leading, .top, .trailing], 15)
            
            
            AddRoundButtons()
        }
        .background {
            Color.brown
        }
        .cornerRadius(30)
        .shadow(color: .black, radius: 10, x: 4, y: 5)
    }
    
    // MARK: InputRoundView
    @ViewBuilder func InputRoundView() -> some View {
        Group {
            switch self.gameViewModel.state {
            case .creatingNewRound:
                TarotAddRoundView(game: game) { round in
                    self.gameViewModel.appendRound(round: round)
                } cancel: {
                    self.gameViewModel.resetState()
                }
            case .modifyingRound(let roundIndex):
                TarotAddRoundView(
                    game: self.game,
                    round: game.rounds[roundIndex].round
                ) { round in
                    self.gameViewModel.modifyRound(index: roundIndex, round: round)
                } cancel: {
                    self.gameViewModel.resetState()
                } delete: {
                    self.gameViewModel.removeRound(index: roundIndex)
                }
            default:
                EmptyView()
            }
        }
        .opacity(0.7)
        .padding()
    }
    
    // MARK: ButtonsFooter
    @ViewBuilder func AddRoundButtons() -> some View {
        HStack {
            
            Button {
                self.gameViewModel.appendFausseDone()
            } label: {
                NewFausseDonneView()
            }
            .tarotButton()
            
            Button {
                self.gameViewModel.state = .creatingNewRound
            } label: {
                NewRoundView()
            }
            .tarotButton()
            
        }
    }
    
    // MARK: FooterButtons
    @ViewBuilder func FooterButtons() -> some View {
        HStack {
            CloseGameButton()
            TarotGameSettingsButton(game: self.game)
            ShareGameButton()
        }
    }
    
    struct CloseGameButton: View {
        @EnvironmentObject private var appViewModel: TarotAppViewModel
        @State private var confirmQuitSheet: Bool = false
        
        var body: some View {
            Button {
                confirmQuitSheet = true
            } label: {
                Image(systemName: "chevron.backward")
            }
            .tarotButton()
            .confirmationDialog("Sure wanna quit ?", isPresented: $confirmQuitSheet) {
                Button("Quit Game") {
                    self.appViewModel.closeGame()
                }
            } message: {
                Text("Sure Sure ?")
            }
            
        }
    }
    
    struct ShareGameButton: View {
        @EnvironmentObject private var gameViewModel: TarotGameViewModel
        
        @State private var capturedImage: Image? = nil
        
        var body: some View {
            ShareItemButton(item: {
                if #available(iOS 16.0, *) {
                    return gameToImageWithImageRenderer()
                } else {
                    return gameToImageWithGraphicsImageRenderer()
                }
            })
            .tarotButton()
            
        }
        
        func makeGameView() -> some View {
            TarotPlayerScoreTableView(game: self.gameViewModel.game)
                .frame(width: 1200)
        }
        
        @available(iOS 16.0, *)
        func gameToImageWithImageRenderer() -> UIImage {
            let renderer = ImageRenderer(content: makeGameView())
            return renderer.uiImage!
        }
        
        func gameToImageWithGraphicsImageRenderer() -> UIImage {
            let gameView = makeGameView()
            let controller = UIHostingController(rootView: gameView)
            
            let view = controller.view
            let targetSize = controller.view.intrinsicContentSize
            let renderer = UIGraphicsImageRenderer(size: targetSize)
            let image = renderer.image { _ in
                view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
            }
            return image
        }
    }
    
    // MARK: Background
    @ViewBuilder func Background() -> some View {
        GrassBackground().blur(radius: 1)
    }
}

#Preview {
    TarotAppGameView(game: TarotGame(players: ["Arthur", "Guillaume", "Adrien"])!)
        .environmentObject(TarotAppViewModel())
}
