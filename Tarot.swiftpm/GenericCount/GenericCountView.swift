import SwiftUI

struct GenericCountView: View {
    
    var exitClosure: (() -> ())?
    
    struct Player: Codable {
        var name: String = ""
        var points: Int = 0
    }
    
    @State private var players: [Player] = [.init(), .init()]
    @State private var step: Int = 1
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                VStack {
                    ForEach(players.indices, id: \.self) { index in
                        HStack {
                            TextField("player \(index + 1)", text: $players[index].name)
                                .playerNameBox(active: false)
                            Button("-") {
                                players[index].points -= step
                            }
                            .tarotButton()
                            TextField("score j\(index + 1)", value: $players[index].points, formatter: NumberFormatter())
                                .minimumScaleFactor(0.2)
                                .multilineTextAlignment(.center)
                                .frame(width: 50)
                            Button("+") {
                                players[index].points += step
                            }
                            .tarotButton()
                        }
                    }
                }
            }
            .padding()
            .background(WoodenBackground())
            
            HStack {
                Button("-") {
                    step -= 1
                }
                .tarotButton()
                TextField("Step", value: $step, formatter: NumberFormatter())
                    .multilineTextAlignment(.center)
                    .frame(width: 50)
                Button("+") {
                    step += 1
                }
                .tarotButton()
            }
            HStack {
                Button("-") {
                    if !players.isEmpty {
                        players.removeLast()
                    }
                }
                .tarotButton()
                Text("\(players.count) Players ")
                Button("+") {
                    players.append(.init())
                }
                .tarotButton()
            }
            
            if let exitClosure = exitClosure {
                Button("Exit", action: exitClosure)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GrassBackground())
    }
}

struct GenericCountView_Previews: PreviewProvider {
    static var previews: some View {
        GenericCountView()
    }
}
