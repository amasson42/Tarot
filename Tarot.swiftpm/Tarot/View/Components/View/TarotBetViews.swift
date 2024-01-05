import SwiftUI

struct TarotBetView: View {
    
    let bet: TarotBet

    var body: some View {
        switch self.bet {
        case .fausseDonne:
            BetFausseDonneView()
        case .petite:
            BetPetiteView()
        case .pouce:
            BetPouceView()
        case .garde:
            BetGardeView()
        case .gardeSans:
            BetGardeSansView()
        case .gardeContre:
            BetGardeContreView()
        }
    }
}

struct BetFausseDonneView: View {
    var body: some View {
        ZStack {
            Text("🃏")
            Text("❌")
            VStack {
                Spacer()
                Text("Boloss !")
                    .foregroundColor(.gray)
            }
        }
        .font(.system(size: 500))
        .minimumScaleFactor(0.01)
    }
}

struct BetPetiteView: View {
    var body: some View {
        ZStack {
            Text("")
            Text("🥄")
        }
        .font(.system(size: 500))
        .minimumScaleFactor(0.01)
    }
}

struct BetPouceView: View {
    var body: some View {
        ZStack {
            Text("")
            Text("🗡")
        }
        .font(.system(size: 500))
        .minimumScaleFactor(0.01)
    }
}

struct BetGardeView: View {
    var body: some View {
        ZStack {
            Text("")
            Text("⚔️")
        }
        .font(.system(size: 500))
        .minimumScaleFactor(0.01)
    }
}

struct BetGardeSansView: View {
    var body: some View {
        ZStack {
            Text("⚜️")
            Text("⚔️")
        }
        .font(.system(size: 500))
        .minimumScaleFactor(0.01)
    }
}

struct BetGardeContreView: View {
    var body: some View {
        ZStack {
            Text("👑")
            Text("⚔️")
        }
        .font(.system(size: 500))
        .minimumScaleFactor(0.01)
    }
}

#Preview {
    VStack {
        ForEach(TarotBet.allCases,
                id: \.hashValue) { bet in
            TarotBetView(bet: bet)
                .frame(width: 50.0, height: 50.0)
                .border(Color.blue)
        }
    }
}
