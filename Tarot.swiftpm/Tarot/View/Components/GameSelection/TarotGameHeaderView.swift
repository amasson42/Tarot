import SwiftUI

struct TarotGameHeaderView: View {
    
    let header: TarotGame.Header
    
    var body: some View {
        VStack {
            VStack {
                Text(header.name)
                    .font(.headline)
                Text("\(header.date.formatted(.dateTime.month().day().hour()))")
                    .font(.subheadline)
            }
            HStack {
                ForEach(header.scores.indices, id: \.self) { i in
                    VStack(spacing: 0) {
                        Text("\(header.scores[i].playerName)")
                            .font(.footnote)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity)
                        Text("\(header.scores[i].score)")
                            .font(.footnote)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(width: 200)
        }
        .background {
            header.color
        }
    }
}

#Preview {
    TarotGameHeaderView(header: .init())
}
