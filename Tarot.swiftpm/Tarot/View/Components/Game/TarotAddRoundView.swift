import SwiftUI

/// Utility window from Counting App feature
/// Can create a new TarotRound from interfaces inputs and will send the result in the action closure
struct TarotAddRoundView: View {

    @ObservedObject var game: TarotGame

    var action: (TarotRound) -> ()
    var cancel: () -> ()
    var delete: (() -> ())?
    
    @State private var bet: TarotBet?
    @State private var mainPlayer: Int?
    @State private var secondPlayer: Int?
    @State private var won: Bool?
    @State private var overflow: TarotRoundOverflow?
    @State private var sideGains: [TarotRound.AttributedSideGain] = []
    
    init(game: TarotGame,
         round: TarotRound? = nil,
         action: @escaping (TarotRound) -> () = { _ in },
         cancel: @escaping () -> () = {},
         delete: (() -> ())? = nil
    ) {
        self.game = game
        self.action = action
        self.cancel = cancel
        self.delete = delete
        
        if let round {
            self._bet = State(initialValue: round.bet)
            self._mainPlayer = State(initialValue: round.mainPlayer)
            self._secondPlayer = State(initialValue: round.secondPlayer)
            self._won = State(initialValue: round.won)
            self._overflow = State(initialValue: round.overflow)
            self._sideGains = State(initialValue: round.attributedSideGains)
        }
    }
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                VStack {
                    
                    if let bet, bet == .fausseDonne {
                        TarotBetView(bet: bet)
                            .frame(maxWidth: 200)
                        
                        PlayerPickerView(players: game.players, main: $mainPlayer, second: .constant(nil))
                    }
                    
                    BetPickerView(bet: $bet)
                        .frame(height: 150)
                    
                    if bet != nil {
                        PlayerPickerView(players: game.players,
                                         main: $mainPlayer,
                                         second: $secondPlayer)
                        
                        if mainPlayer != nil {
                            ScorePickerView(won: $won, overflow: $overflow)
                            
                        }
                        
                        Spacer(minLength: 85)
                        SideGainsView(players: game.players,
                                      sideGains: $sideGains)
                        
                    }
                    
                    ScrollView {
                        Text(round?.description(withPlayers: game.players) ?? "")
                    }
                    
                    Spacer()
                    
                }
            }
            
            HStack {
                
                if let round {
                    Button("Ok") {
                        action(round)
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Button("Cancel", role: .cancel) {
                    cancel()
                }
                
                if let delete {
                    Button("Delete", role: .destructive) {
                        delete()
                    }
                }
                
            }.padding()
        }.padding()
    }
    
    // MARK: BetPickerView
    struct BetPickerView: View {
        @Binding var bet: TarotBet?
        @Namespace private var betAnimation
        
        var body: some View {
            GeometryReader { proxy in
                VStack {
                    HStack(spacing: 0) {
                        ForEach(TarotBet.bets, id: \.hashValue) { bet in
                            Button {
                                withAnimation {
                                    self.bet = bet
                                }
                            } label: {
                                VStack {
                                    TarotBetView(bet: bet)
                                        .frame(height: 50)
                                        .matchedGeometryEffect(id: bet, in: betAnimation, isSource: true)
                                }
                                .background(WoodenBackground())
                                .frame(width: proxy.size.width / CGFloat(TarotBet.bets.count), height: 80)
                                .betSelector(bet: bet, selected: self.bet == bet)
                                
                            }
                        }
                    }
                    Text("\(bet?.description ?? "")")
                }
            } // Geometry Reader
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
                    ForEach(players.indices, id: \.self) { pi in
                        
                        Button {
                            main = pi
                        } label: {
                            Text("\(players[pi])")
                                .foregroundColor(.black)
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)
                        }
                        .disabled(main == pi)
                        .playerNameBox(active: main == pi)
                        
                    }
                }
                
                if players.count == 5 {
                    Text("🤝")
                    
                    VStack {
                        ForEach(players.indices, id: \.self) { pi in
                            
                            Button {
                                second = pi
                            } label: {
                                Text("\(players[pi])")
                                    .foregroundColor(.black)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)
                            }
                            .disabled(second == pi)
                            .playerNameBox(active: second == pi)
                            
                        }
                    }
                    
                }
            }
        }
        
    }
    
    // MARK: ScorePickerView
    struct ScorePickerView: View {
        @Binding var won: Bool?
        @Binding var overflow: TarotRoundOverflow?
        
        @State private var pickerChoice: Int?
        @State private var sliderChoice: Int = choices.count / 2
        
        struct Choice: Equatable {
            let won: Bool
            let overflow: TarotRoundOverflow
        }
        
        static let choices: [Choice] =
        TarotRoundOverflow.allCases.reversed().map {
            Choice(won: false, overflow: $0)
        } + TarotRoundOverflow.allCases.map {
            Choice(won: true, overflow: $0)
        }
        
        init(won: Binding<Bool?>, overflow: Binding<TarotRoundOverflow?>) {
            self._won = won
            self._overflow = overflow
            
            if let wonW = won.wrappedValue,
               let overflowW = overflow.wrappedValue {
                
                self._pickerChoice = State(initialValue: Self.choices.firstIndex(of: Choice(won: wonW, overflow: overflowW)))
            }
            
        }
        
        var body: some View {
            
            VStack {
                
                Picker("", selection: $pickerChoice) {
                    ForEach(Self.choices.indices, id: \.self) { i in
                        Text("\(Self.choices[i].overflow.value)")
                            .foregroundColor(Self.choices[i].won ? .green : .red)
                            .tag(i as Int?)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: pickerChoice) { i in
                    if let i = i {
                        won = Self.choices[i].won
                        overflow = Self.choices[i].overflow
                    } else {
                        won = nil
                        overflow = nil
                    }
                }
            }
        }
    }
    
    // MARK: SideGainsView
    struct SideGainsView: View {
        
        let players: [String]
        @Binding var sideGains: [TarotRound.AttributedSideGain]
        
        let allGains = TarotSideGain.allCases
        
        let gridLayout = [GridItem](repeating: .init(.flexible()), count: 2)
        
        @State private var selectedGain: TarotSideGain?
        
        var body: some View {
            
            VStack {
                
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
                        
                        ForEach(allGains.indices, id: \.self) { i in
                            
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
                            
                            ForEach(players.indices, id: \.self) { i in
                                Button {
                                    
                                    let newGain = TarotRound.AttributedSideGain(player: i, gain: selectedGainW)
                                    
                                    sideGains.append(newGain)
                                    
                                    selectedGain = nil
                                } label: {
                                    Text("\(players[i])")
                                        .foregroundColor(.black)
                                        .modifier(PlayerNameBox(active: false))
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
    
    var round: TarotRound? {
        guard let bet = bet,
              let mainPlayer = mainPlayer,
              let won = won,
              let overflow = overflow
        else { return nil }
        
        let secondPlayer = mainPlayer == secondPlayer ? nil : secondPlayer
        return TarotRound(playerCount: game.players.count,
                          mainPlayer: mainPlayer,
                          secondPlayer: secondPlayer,
                          won: won,
                          overflow: overflow,
                          bet: bet,
                          attributedSideGains: sideGains)
    }
}

#Preview {
    TarotAddRoundView(
        game: TarotGame(players: ["Adrien", "Guillaume", "Arthur", "Nicolas", "Maman"])!,
        round: TarotRound(playerCount: 5, mainPlayer: 1, secondPlayer: 0, won: true, overflow: .p0, bet: .garde, attributedSideGains: [
            .init(player: 0, gain: .misery),
            .init(player: 2, gain: .doublePoignee)
        ])) {
            round in
            print("New game: \(round.description)")
        } cancel: {
            print("Cancelled")
        }
}

#Preview {
    TarotAddRoundView.SideGainsView(players: ["Adrien", "Guillaume", "Arthur", "Nicolas", "Maman"], sideGains: .constant([
        .init(player: 0, gain: .misery),
        .init(player: 1, gain: .petitAuBout)
    ]))
}
