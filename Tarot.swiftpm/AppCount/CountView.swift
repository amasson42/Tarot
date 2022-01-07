//
//  CountAppView.swift
//  Tarot
//
//  Created by Giantwow on 27/12/2021.
//

import SwiftUI

struct CountTableView: View { 
    
    @StateObject private var gameList: TarotGameList
    
    @State private var showInputGame: Bool = false
    
    let layout: [GridItem]
    
    init(playerNames: [String]) {
        let tarotGameList = TarotGameList(players: playerNames)
        playerNames.indices.forEach { tarotGameList.addFausseDonne(forPlayer: $0) }
        
        self._gameList = .init(wrappedValue: tarotGameList)
        self.layout = .init(repeating: .init(), count: playerNames.count)
    }
    
    var body: some View {
        
        ZStack {
            
            // Players table
            ScrollView {
                LazyVGrid(columns: layout) {
                    ForEach(gameList.players.indices) { pi in
                        Text(gameList.players[pi])
                            .fontWeight(.bold)
                            .lineLimit(1)
                    }
                    ForEach(gameList.gameHistory) { game in
                        ForEach(gameList.players.indices) { pi in
                            Text("\(game.score(forPlayer: pi))")
                                .lineLimit(1)
                        }
                    }
                    ForEach(gameList.players.indices) { pi in
                        Text("\(gameList.scores[pi])")
                            .fontWeight(.heavy)
                            .lineLimit(1)
                    }
                }
            }
            .blur(radius: showInputGame ? 5 : 0)
            
            // Add game button
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    Button("Add game") {
                        showInputGame = true
                    }
                    .padding()
                }
            }
            
            if showInputGame {
                Color.gray.opacity(0.7)
                    .padding()
                    .onTapGesture {
                        gameList.addFausseDonne(forPlayer: gameList.players.indices.randomElement()!)
                        showInputGame = false
                    }
            }
            
        }
        
    }
}

struct CountAppView: View {
    
    @State private var playerList: [String] = []
    
    var body: some View {
        VStack {
            
            NavigationLink("Set players",
                           destination: PlayerInputView(playerList: $playerList))
            
#if DEBUG
            Button("[Debug] Add players") {
                self.playerList = ["Adrien", "Guillaume", "Arthur", "Nicolas", "Maman"]
            }
#endif
            
            VStack {
                Text("Players")
                VStack {
                    ForEach(playerList.indices, id: \.self) { i in
                        Text(playerList[i])
                    }
                }
                .background(Color.gray.opacity(0.3))
                .padding()
            }.border(.blue, width: 1.0)
            
            if TarotGame.playerRange.contains(self.playerList.count) {
                NavigationLink("Start", destination: CountTableView(playerNames: playerList))
            }
            
        }
    }
    
}

struct PlayerInputView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @Binding var playerList: [String]
    
    @State private var players = [String](repeating: "", count: TarotGame.playerRange.upperBound)
    
    var body: some View {
        HStack {
            VStack {
                ForEach(0..<players.count) { i in
                    TextField("Name of player \(i)", text: $players[i])
                }
            }
            Button("Done") {
                playerList = players.filter { !$0.isEmpty }
                dismiss()
            }
        }
        .onAppear {
            for i in playerList.indices {
                players[i] = playerList[i]
            }
        }
    }
    
}

struct CountAppView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CountAppView()
        }
    }
}
