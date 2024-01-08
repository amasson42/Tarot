import SwiftUI

struct TarotGameParametersView: View {

    var playerNameBinds: [Binding<String>]
    
    @Binding var gameName: String
    @Binding var gameColor: Color

    var playerNames: [String] {
        playerNameBinds.map(\.wrappedValue).filter { !$0.isEmpty }
    }
    
    var body: some View {
        VStack {
            
            VStack {
                ForEach(playerNameBinds.indices, id: \.self) {
                    i in
                    TextField("empty spot", text: playerNameBinds[i])
                        .playerNameBox(active: false)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.words)
                        .padding(.horizontal)
                        .tag(i)
                }
            }
            
            HStack {
                
                ColorPicker(selection: $gameColor, label: {
                    EmptyView()
                })
                
                TextField("game name", text: $gameName)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.words)
                    .onSubmit {
                        
                    }
            }
            
        }
    }
}
