import SwiftUI

struct TarotSelectOldGameView: View {
    
    var action: (TarotGameList) -> () = { _ in }
    var cancel: () -> () = {}
    
    @State var savedGames: [TarotGameList.Header] = []
    
    var body: some View {
        List {
            ForEach(savedGames) { savedGame in
                Button {
                    do {
                        let game = try savedGame.load()
                        action(game)
                    } catch {
                        print("error loading game \(savedGame.name): \(error.localizedDescription)")
                    }
                } label: {
                    TarotGameListHeaderView(header: savedGame)
                }
            }
            .onDelete { indices in
                for index in indices {
                    do {
                        try savedGames[index].delete()
                    } catch {
                        print("error deleting game \(savedGames[index]): \(error.localizedDescription)")
                    }
                }
                savedGames.remove(atOffsets: indices)
            }
        }
        .onAppear {
            savedGames = TarotGameList.listGames()
        }
    }
}

struct TarotGameListHeaderView: View {
    
    let header: TarotGameList.Header
    
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

struct TarotSelectOldGameView_Previews: PreviewProvider {
    static var previews: some View {
        TarotSelectOldGameView()
    }
}
