import SwiftUI

extension TarotGameSideGain: View {
    var body: some View {
        switch self {
        case .misery:
            return SideGainMiseryView()
        case .doubleMisery:
            return SideGainDoubleMiseryView()
        case .poignee:
            return SideGainPoigneeView()
        case .doublePoignee:
            return SideGainDoublePoigneeView()
        case .petitAuBout:
            return SideGainPetitAuBoutView()
        case .petitAuBouffe:
            return SideGainPetitAuBouffeView()
        case .bonus:
            return SideGainBonusView()
        case .malus:
            return SideGainMalusView()
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
