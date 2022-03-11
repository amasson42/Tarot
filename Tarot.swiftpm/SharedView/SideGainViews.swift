import SwiftUI

extension TarotGameSideGain: View {
    var body: some View {
        switch self {
        case .misery:
            SideGainMiseryView()
        case .doubleMisery:
            SideGainDoubleMiseryView()
        case .poignee:
            SideGainPoigneeView()
        case .doublePoignee:
            SideGainDoublePoigneeView()
        case .petitAuBout:
            SideGainPetitAuBoutView()
        case .petitAuBouffe:
            SideGainPetitAuBouffeView()
        case .bonus:
            SideGainBonusView()
        case .malus:
            SideGainMalusView()
        }
    }
}

struct SideGainMiseryView: View {
    var body: some View {
        ZStack {
            Text("💨")
        }
        .font(.system(size: 500))
        .minimumScaleFactor(0.01)
    }
}

struct SideGainDoubleMiseryView: View {
    var body: some View {
        ZStack {
            Text("🌪")
        }
        .font(.system(size: 500))
        .minimumScaleFactor(0.01)
    }
}

struct SideGainPoigneeView: View {
    var body: some View {
        ZStack {
            Text("🥌")
        }
        .font(.system(size: 500))
        .minimumScaleFactor(0.01)
    }
}

struct SideGainDoublePoigneeView: View {
    var body: some View {
        ZStack {
            Text("🤝")
        }
        .font(.system(size: 500))
        .minimumScaleFactor(0.01)
    }
}

struct SideGainPetitAuBoutView: View {
    var body: some View {
        ZStack {
            Text("🎖")
        }
        .font(.system(size: 500))
        .minimumScaleFactor(0.01)
    }
}

struct SideGainPetitAuBouffeView: View {
    var body: some View {
        ZStack {
            Text("🪦")
        }
        .font(.system(size: 500))
        .minimumScaleFactor(0.01)
    }
}

struct SideGainBonusView: View {
    var body: some View {
        ZStack {
            Text("✨")
        }
        .font(.system(size: 500))
        .minimumScaleFactor(0.01)
    }
}

struct SideGainMalusView: View {
    var body: some View {
        ZStack {
            Text("❌")
        }
        .font(.system(size: 500))
        .minimumScaleFactor(0.01)
    }
}
