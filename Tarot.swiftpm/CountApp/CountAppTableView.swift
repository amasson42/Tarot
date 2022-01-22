//
//  CountAppTableView.swift
//  Tarot
//
//  Created by Giantwow on 27/12/2021.
//

import SwiftUI

struct CountAppTableView: View { 
    
    @StateObject private var gameList: TarotGameList
    
    @State private var showInputGame: Bool = false
    @State private var inputGameIndex: Int? = nil
    
    let layout: [GridItem]
    
    init(playerNames: [String]) {
        let tarotGameList = TarotGameList(players: playerNames)
        
        self._gameList = .init(wrappedValue: tarotGameList)
        self.layout = .init(repeating: .init(), count: playerNames.count)
    }
    
    var body: some View {
        
        ZStack {
            
            Group {
                // Players table
                ScrollView {
                    CountAppPlayerScoreTable(gameList: gameList) {
                        showInputGame = true
                        inputGameIndex = $1
                    }
                }
                
                // Add game button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button("Add game") {
                            showInputGame = true
                        }
                        .padding()
                    }
                }
            }
            .padding()
            .disabled(showInputGame)
            .blur(radius: showInputGame ? 5 : 0)
            
            if showInputGame {
                
                if let gi = inputGameIndex {
                    
                    CountAppAddGameView(gameList: gameList,
                                        game: gameList.gameHistory[gi]) { game in
                        gameList.gameHistory[gi] = game
                        showInputGame = false
                        inputGameIndex = nil
                    } cancel: { 
                        showInputGame = false
                        inputGameIndex = nil
                    }
                    .opacity(0.7)
                    .padding()
                    
                } else {
                    CountAppAddGameView(gameList: gameList) { game in
                        gameList.gameHistory.append(game)
                        showInputGame = false
                        inputGameIndex = nil
                    } cancel: {
                        showInputGame = false
                        inputGameIndex = nil
                    }
                    .opacity(0.7)
                    .padding()
                    
                }
                
            }
            
        }
        
    }
}

struct CountAppTableView_Previews: PreviewProvider {
    
    static let names = ["Adrien", "Guillaume", "Arthur", "Nicolas", "Maman"]
    
    static var previews: some View {
        CountAppTableView(playerNames: names)
    }
}

