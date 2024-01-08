import SwiftUI

struct ClassmentView: View {
    var classment: Int
    
    var body: some View {
        switch classment {
        case 1:
            Text("🥇")
        case 2:
            Text("🥈")
        case 3:
            Text("🥉")
        case 4:
            Text("💝")
        case 5:
            Text("💩")
        default:
            Text(" ")
        }
    }
}

struct GameCumulView: View {
    var gameCumul: TarotGame.ScoreCumul
    
    var body: some View {
        VStack {
            Text("\(gameCumul.score)")
                .bold()
                .lineLimit(1)
                .minimumScaleFactor(0.2)
                .frame(maxWidth: .infinity)
            
            HStack(spacing: 0) {
                
                PositionChangerView(positionChanger: gameCumul.positionChanger)
                    .minimumScaleFactor(0.2)
                
                ClassmentView(classment: gameCumul.classment)
                
            }
        }
    }
    
    @ViewBuilder func PositionChangerView(positionChanger: TarotGame.PositionChanger) -> some View {
        switch positionChanger {
        case .stay:
            Text("-")
                .foregroundColor(.gray)
        case .increase:
            Text("↗")
                .foregroundColor(.green)
        case .decrease:
            Text("↘")
                .foregroundColor(.red)
        }
    }
    
}

struct DistributorIndicator: View {
    var body: some View {
        ZStack {
            Image(systemName: "arrow.down")
                .foregroundColor(Color.gray)
                .offset(x: 0, y: 10)
            Text("🃏")
                .rotationEffect(Angle(degrees: 15))
                .shadow(radius: 2)
                .offset(x: 5, y: 1)
            Text("🃏")
                .rotationEffect(Angle(degrees: 0))
                .shadow(radius: 2)
            Text("🃏")
                .rotationEffect(Angle(degrees: -15))
                .shadow(radius: 3)
                .offset(x: -5, y: 1)
                .rotation3DEffect(Angle(degrees: 20), axis: (0, 1, 0))
        }
    }
}

struct NewFausseDonneView: View {
    var body: some View {
        ZStack {
            BetFausseDonneView()
            
            Image(systemName: "plus")
                .resizable()
                .opacity(0.7)
            
        }
        .frame(width: 45, height: 45)
    }
}

struct NewRoundView: View {
    var body: some View {
        ZStack {
            Group {
                Text("🃏")
                    .rotationEffect(Angle(degrees: 15))
                    .shadow(radius: 2)
                    .offset(x: 5, y: 1)
                Text("🃏")
                    .rotationEffect(Angle(degrees: 0))
                    .shadow(radius: 2)
                Text("🃏")
                    .rotationEffect(Angle(degrees: -15))
                    .shadow(radius: 3)
                    .offset(x: -5, y: 1)
                    .rotation3DEffect(Angle(degrees: 20), axis: (0, 1, 0))
                Text("⚔️")
            }
            .font(.system(size: 500))
            .minimumScaleFactor(0.01)
            
            Image(systemName: "plus")
                .resizable()
                .opacity(0.7)
        }
        .frame(width: 45, height: 45)
    }
}

#Preview {
    VStack {
        
        HStack {
            ForEach(1...5, id: \.self) { classment in
                ClassmentView(classment: classment)
            }
        }
        
        HStack {
            ForEach(
                [
                    TarotGame.ScoreCumul(score: 500, classment: 1, positionChanger: .increase),
                    TarotGame.ScoreCumul(score: 250, classment: 2, positionChanger: .increase),
                    TarotGame.ScoreCumul(score: 0, classment: 3, positionChanger: .stay),
                    TarotGame.ScoreCumul(score: -250, classment: 4, positionChanger: .decrease),
                    TarotGame.ScoreCumul(score: -500, classment: 5, positionChanger: .decrease),
                ], id: \.classment) { cumul in
                    GameCumulView(gameCumul: cumul)
                }
        }
        
        DistributorIndicator()
    }
}
