//
//  CountAppView.swift
//  Tarot
//
//  Created by Giantwow on 27/12/2021.
//

import SwiftUI

struct CountAppView: View {
    
    var exitClosure: (() -> ())?
    @State private var playerList: [String] = []
    @State private var playerInputActive: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    
                    Button("Set players") {
                        playerInputActive = true
                    }
                    
                    //#if DEBUG
                    Button("[Debug] Add players") {
                        self.playerList = ["Adrien", "Guillaume", "Arthur", "Nicolas", "Maman"]
                    }
                    //#endif
                    
                    VStack {
                        Text("Players")
                        VStack {
                            ForEach(playerList.indices, id: \.self) { i in
                                Text(playerList[i])
                            }
                        }
                        .background(Color.gray.opacity(0.3))
                        .padding()
                    }
                    
                    if TarotGame.playerRange.contains(self.playerList.count) {
                        NavigationLink("Start", destination: CountAppTableView(playerNames: playerList))
                    }
                    
                    if let exitClosure = exitClosure {
                        Button("Exit") {
                            exitClosure()
                        }
                    }
                    
                }
                .blur(radius: playerInputActive ? 5 : 0)
                .disabled(playerInputActive)
                
                if playerInputActive {
                    PlayerInputView(isActive: $playerInputActive, playerList: $playerList)
                        .background(Color.secondary.opacity(0.9))
                        .padding()
                }
                
            }
        }
    }
    
}

struct PlayerInputView: View {
    
    @Binding var isActive: Bool
    @Binding var playerList: [String]
    
    @State private var players = [String](repeating: "", count: TarotGame.playerRange.upperBound)
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button { 
                    isActive = false
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .frame(width: 30, height: 30)
                }
                
            }
            VStack {
                ForEach(0..<players.count) { i in
                    TextField("Name of player \(i + 1)", text: $players[i])
                }
            }
            Button("Done") {
                playerList = players.filter { !$0.isEmpty }
                isActive = false
            }
            .padding()
            .buttonStyle(.bordered)
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
