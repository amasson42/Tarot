import SwiftUI

// MARK: PlayerNameBox
struct PlayerNameBox: ViewModifier {
    
    let active: Bool
    
    let contentColors = [#colorLiteral(red: 0.13470306992530823, green: 0.17004701495170593, blue: -3.008171933771564e-09, alpha: 1.0), #colorLiteral(red: 0.9245002865791321, green: 0.6999923586845398, blue: -9.626150188069005e-08, alpha: 0.7865927124023437), #colorLiteral(red: 0.3984828591346741, green: 0.3337665796279907, blue: -1.2032687735086256e-08, alpha: 1.0)].map(Color.init)
    let boundColors = [#colorLiteral(red: 0.14507105946540833, green: 0.10427399724721909, blue: -1.504085966885782e-09, alpha: 1.0), #colorLiteral(red: 0.28616076707839966, green: 0.20821180939674377, blue: -1.8049032490807804e-08, alpha: 1.0), #colorLiteral(red: 0.36616674065589905, green: 0.17665383219718933, blue: 6.016343867543128e-09, alpha: 1.0)].map(Color.init)
    let cr: CGFloat = 15
    
    func body(content: Content) -> some View {
        content.padding(10).background {
            LinearGradient(colors: contentColors,
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .clipShape(RoundedRectangle(cornerRadius: cr))
            RoundedRectangle(cornerRadius: cr)
                .stroke(LinearGradient(colors: boundColors,
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing),
                        lineWidth: 10)
                .shadow(radius: 6, x: 3, y: 3)
                .shadow(color: active ? .green : .black, radius: active ? 10 : 0)
                .clipShape(RoundedRectangle(cornerRadius: cr))
                .animation(.linear, value: active)
                .overlay {
                    RoundedRectangle(cornerRadius: cr - 3)
                        .stroke(active ? .green : .black)
                        .padding(3)
                }
        }
    }
    
}

struct BetSelector: ViewModifier {
    let bet: TarotGameBet
    func body(content: Content) -> some View {
        switch bet {
        case .petite:
            return content.overlay {
                Color.gray.opacity(0.1)
            }
        case .pouce:
            return content.overlay {
                Color.gray.opacity(0.2)
            }
        case .garde:
            return content.overlay {
                Color.gray.opacity(0.3)
            }
        case .gardeSans:
            return content.overlay {
                Color.gray.opacity(0.4)
            }
        case .gardeContre:
            return content.overlay {
                Color.gray.opacity(0.5)
            }
        default:
            return content
        }
    }
}

struct TarotButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.quaternary, in: Capsule())
    }
}

extension View {
    func playerNameBox(active: Bool) -> some View {
        self
            .font(.custom("chalkduster", size: 18))
            .modifier(PlayerNameBox(active: active))
    }
    
    func betSelector(bet: TarotGameBet, selected: Bool) -> some View {
        if selected {
            return modifier(BetSelector(bet: bet))
        } else {
            return self
        }
    }
    
    func tarotButton() -> some View {
        modifier(TarotButton())
    }
}

struct UIDesign_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Active")
                .playerNameBox(active: true)
            Text("Inactive")
                .playerNameBox(active: false)
            HStack {
                ForEach(TarotGameBet.bets, id: \.hashValue) { bi in
                    bi
                        .frame(width: 40, height: 40)
                        .betSelector(bet: bi, selected: true)
                }
            }
            HStack {
                ForEach(TarotGameBet.bets, id: \.hashValue) { bi in
                    bi
                        .frame(width: 40, height: 40)
                        .betSelector(bet: bi, selected: false)
                }
            }
        }
        .padding()
        .background(.gray)
    }
}
