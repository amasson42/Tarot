import SwiftUI

struct TarotSelectOldGameView: View {
    
    let gameManager: any TarotGameManagerProtocol
    
    var action: (TarotGame) -> () = { _ in }
    var cancel: () -> () = {}
    
    @State var savedGames: [TarotGame.Header] = []
    
    var body: some View {
        List {
            ForEach(savedGames) { savedGame in
                Button {
                    do {
                        let game = try gameManager.load(header: savedGame)
                        action(game)
                    } catch {
                        print("error loading game \(savedGame.name): \(error.localizedDescription)")
                    }
                } label: {
                    TarotGameHeaderView(header: savedGame)
                }
            }
            .onDelete { indices in
                for index in indices {
                    do {
                        try gameManager.delete(header: savedGames[index])
                    } catch {
                        print("error deleting game \(savedGames[index]): \(error.localizedDescription)")
                    }
                }
                savedGames.remove(atOffsets: indices)
            }
        }
        .onAppear {
            savedGames = gameManager.getAllHeaders()
        }
    }
}

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
    TarotSelectOldGameView(gameManager: TarotGameManager_Mock())
}

