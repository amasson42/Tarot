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
