import SwiftUI

extension TarotGameBet: View {
    var body: some View {
        switch self {
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

struct BetViews_Previews: PreviewProvider {
    
    @State static var width: CGFloat = 50
    
    static var previews: some View {
        VStack {
            ForEach(TarotGameBet.allCases, id: 
                        \.hashValue) {
                $0
                    .frame(width: width, height: width)
                    .border(Color.blue)
            }
        }
    }
}
