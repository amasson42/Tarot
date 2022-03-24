//
//  SwiftUIView.swift
//  
//
//  Created by Giantwow on 24/03/2022.
//

import SwiftUI

struct CountAppSelectOldGameView: View {
    
    var action: (TarotGameList) -> () = { _ in }
    var cancel: () -> () = {}
    
    @State var savedGames: [TarotGameList.Header] = []
    
    var body: some View {
        List {
            ForEach(savedGames.indices, id: \.self) { gameIndex in
                let savedGame = savedGames[gameIndex]
                Button {
                    do {
                        let game = try savedGame.load()
                        action(game)
                    } catch {
                        print("error loading game \(savedGame.name): \(error.localizedDescription)")
                    }
                } label: {
                    CountAppTarotGameListHeaderView(header: savedGame)
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

struct CountAppTarotGameListHeaderView: View {
    
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
    }
}

struct CountAppSelectOldGameView_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack(spacing: 10) {
            CountAppTarotGameListHeaderView(header: .example0)
                .border(.black)
            CountAppTarotGameListHeaderView(header: .example1)
                .border(.black)
            CountAppTarotGameListHeaderView(header: .example2)
                .border(.black)
        }
    }
}
