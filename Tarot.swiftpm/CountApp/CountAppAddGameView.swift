import SwiftUI

struct CountAppAddGameView: View {
    @ObservedObject var gameList: TarotGameList
    var action: (TarotGameScore) -> ()
    var cancel: () -> ()
    
    @State private var bet: TarotGameBet?
    @State private var mainPlayer: Int?
    @State private var secondPlayer: Int?
    @State private var won: Bool?
    @State private var overflow: TarotGameOverflow?
    @State private var sideGains: [TarotGameScore.SideGain] = []
    
    init(gameList: TarotGameList,
         game: TarotGameScore? = nil,
         action: @escaping (TarotGameScore) -> () = { _ in },
         cancel: @escaping () -> () = {}
    ) {
        self.gameList = gameList
        self.action = action
        self.cancel = cancel
        
        if let game = game {
            self._bet = State(initialValue: game.bet)
            self._mainPlayer = State(initialValue: game.mainPlayer)
            self._secondPlayer = State(initialValue: game.secondPlayer)
            self._won = State(initialValue: game.won)
            self._overflow = State(initialValue: game.overflow)
            self._sideGains = State(initialValue: game.sideGains)
        }
    }
    
    var body: some View {
        VStack {
            
            BetPickerView(bet: $bet)
                .frame(height: 150)
            
            if bet != nil {
                PlayerPickerView(players: gameList.players,
                                 main: $mainPlayer,
                                 second: $secondPlayer)
                
                if mainPlayer != nil {
                    ScorePickerView(won: $won, overflow: $overflow)
                    
                    if won != nil {
                        SideGainsView(players: gameList.players,
                                      sideGains: $sideGains)
                    }
                    
                }
                
            }
            
            ScrollView {
                Text(game?.description(withPlayers: gameList.players) ?? "")
            }
            
            Spacer()
            HStack {
                
                if let game = game {
                    Button("Ok") {
                        action(game)
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Button("Cancel", role: .cancel) {
                    cancel()
                }
                
            }.padding()
            
        }.padding()
    }
    
    // MARK: BetPickerView
    struct BetPickerView: View {
        @Binding var bet: TarotGameBet?
        
        var body: some View {
            if let curBet = bet {
                Button {
                    withAnimation {
                        bet = nil
                    }
                } label: {
                    curBet
                        .scaledToFit()
                }
            } else {
                HStack {
                    ForEach(TarotGameBet.bets,
                            id: \.hashValue) { bi in
                        Button {
                            withAnimation {
                                bet = bi
                            }
                        } label: {
                            VStack {
                                bi
                                    .frame(height: 40)
                                Text("\(bi.description)")
                                    .minimumScaleFactor(0.1)
                            }
                        }
                        .frame(height: 60)
                        .buttonStyle(.automatic)
                    }
                }
            }
        }
    }
    
    // MARK: PlayerPickerView
    struct PlayerPickerView: View {
        let players: [String]
        @Binding var main: Int?
        @Binding var second: Int?
        
        var body: some View {
            HStack {
                
                VStack {
                    ForEach(players.indices) { pi in
                        
                        Button {
                            main = pi
                        } label: {
                            Text("\(players[pi])")
                        }
                        .disabled(main == pi)
                        
                    }
                }
                
                if players.count == 5 {
                    Text("🤝")
                    
                    VStack {
                        ForEach(players.indices) { pi in
                            
                            Button {
                                second = pi
                            } label: {
                                Text("\(players[pi])")
                            }
                            .disabled(second == pi)
                            
                        }
                    }
                    .onChange(of: main) { _ in
                        second = nil
                    }
                    
                }
            }
        }
        
    }
    
    // MARK: ScorePickerView
    struct ScorePickerView: View {
        @Binding var won: Bool?
        @Binding var overflow: TarotGameOverflow?
        
        @State private var pickerChoice: Int?
        
        struct Choice: Equatable {
            let won: Bool
            let overflow: TarotGameOverflow
        }
        
        let choices: [Choice] = 
        TarotGameOverflow.allCases.reversed().map {
            Choice(won: false, overflow: $0)
        } + TarotGameOverflow.allCases.map {
            Choice(won: true, overflow: $0)
        }
        
        init(won: Binding<Bool?>, overflow: Binding<TarotGameOverflow?>) {
            self._won = won
            self._overflow = overflow
            
            if let wonW = won.wrappedValue,
               let overflowW = overflow.wrappedValue {
                
                self._pickerChoice = State(initialValue: choices.firstIndex(of: Choice(won: wonW, overflow: overflowW)))
            }
            
        }
        
        var body: some View {
            
            Picker("", selection: $pickerChoice) {
                ForEach(choices.indices) { i in
                    Text("\(choices[i].overflow.value)")
                        .foregroundColor(choices[i].won ? .green : .red)
                        .tag(i as Int?)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: pickerChoice) { i in
                if let i = i {
                    won = choices[i].won
                    overflow = choices[i].overflow
                } else {
                    won = nil
                    overflow = nil
                }
            }
            
        }
    }
    
    // MARK: SideGainsView
    struct SideGainsView: View {
        
        let players: [String]
        @Binding var sideGains: [TarotGameScore.SideGain]
        
        let allGains = TarotGameSideGain.allCases
        
        let gridLayout = [GridItem](repeating: .init(.flexible()), count: 2)
        
        @State private var selectedGain: TarotGameSideGain?
        
        var body: some View {
            
            VStack {
                
                Spacer()
                
                HStack {
                    ForEach(sideGains.indices, id: \.self) { i in
                        
                        Button {
                            
                            if sideGains.indices.contains(i) {
                                sideGains.remove(at: i)
                            }
                            
                        } label: {
                            ZStack(alignment: .bottomTrailing) {
                                sideGains[i].gain
                                
                                Text("\(players[sideGains[i].player])")
                                    .lineLimit(1)
                                    .font(.footnote)
                                    .minimumScaleFactor(0.1)
                                    .foregroundColor(.primary)
                            }
                            .frame(width: 50, height: 50)
                            .padding(3)
                            .background {
                                Color.accentColor    
                                    .opacity(0.7)
                                    .padding(3)
                                    .background(Color.gray)
                            }
                            .cornerRadius(10)
                            
                        }
                        
                    }
                }
                .animation(.spring(), value: sideGains)
                .animation(.default, value: selectedGain)
                .frame(minHeight: 55)
                
                ZStack {
                    
                    LazyVGrid(columns: gridLayout) {
                        
                        ForEach(allGains.indices) { i in
                            
                            Button {
                                selectedGain = allGains[i]
                            } label: {
                                allGains[i]
                                    .frame(width: 40, height: 40)
                                Spacer()
                                Text("\(allGains[i].description)")
                                    .lineLimit(2)
                                    .foregroundColor(.primary)
                                    .font(.footnote)
                                    .minimumScaleFactor(0.1)
                            }
                            .padding(5)
                            .background {
                                Color.accentColor
                                    .opacity(0.6)
                                    .cornerRadius(10)
                            }
                            
                        }
                    }
                    .blur(radius: selectedGain != nil ? 4 : 0)
                    .disabled(selectedGain != nil)
                    
                    if let selectedGainW = selectedGain {
                        
                        VStack {
                            
                            selectedGainW
                                .frame(width: 40, height: 40)
                            
                            ForEach(players.indices) { i in
                                Button {
                                    
                                    let newGain = TarotGameScore.SideGain(player: i, gain: selectedGainW)
                                    
                                    sideGains.append(newGain)
                                    
                                    selectedGain = nil
                                } label: {
                                    Text("\(players[i])")
                                }
                                
                            }
                        }
                        .padding()
                        .background {
                            Color.primary
                                .opacity(0.85)
                        }
                        .cornerRadius(10)
                        .onTapGesture {}
                        
                    }
                    
                }
                
            }
            .onTapGesture {
                selectedGain = nil
            }
        }
        
    }
    
    var game: TarotGameScore? {
        guard let bet = bet,
              let mainPlayer = mainPlayer,
              let won = won,
              let overflow = overflow
        else { return nil }
        
        let secondPlayer = mainPlayer == secondPlayer ? nil : secondPlayer
        return TarotGameScore(playerCount: gameList.players.count,
                              mainPlayer: mainPlayer,
                              secondPlayer: secondPlayer,
                              won: won,
                              overflow: overflow,
                              bet: bet,
                              sideGains: sideGains)
    }
}

struct CountAppAddGameView_Previews: PreviewProvider {
    
    static let names_5p = ["Adrien", "Guillaume", "Arthur", "Nicolas", "Maman"]
    
    static let names_3p = ["Adrien", "Guillaume", "Arthur"]
    
    static var previews: some View {
        CountAppAddGameView(gameList: TarotGameList(players: names_5p),
                            game: TarotGameScore(playerCount: 5, mainPlayer: 1, secondPlayer: 0, won: true, overflow: .p0, bet: .garde, sideGains: [
                                .init(player: 0, gain: .misery),
                                .init(player: 2, gain: .doublePoignee)
                            ])) {
                                game in
                                print("New game: \(game.description)")
                            } cancel: {
                                print("Cancelled")
                            }
    }
}

struct CountAppAddGameSideGainsView_Previews: PreviewProvider {
    
    static var previews: some View {
        Previewer()
    }
    
    struct Previewer: View {
        let names_5p = ["Adrien", "Guillaume", "Arthur", "Nicolas", "Maman"]
        
        @State var sideGains: [TarotGameScore.SideGain] = [
            .init(player: 0, gain: .misery),
            .init(player: 1, gain: .petitAuBout)
        ]
        
        var body: some View {
            CountAppAddGameView.SideGainsView(players: names_5p, sideGains: $sideGains)
                .padding()
        }
    }
    
}
