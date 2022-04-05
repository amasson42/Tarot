import SwiftUI

// MARK: PlayerNameBox
struct PlayerNameBox: ViewModifier {
    
    let active: Bool
    
    func body(content: Content) -> some View {
        content.padding().background {
            Color.brown
                .clipShape(RoundedRectangle(cornerRadius: 10))
            RoundedRectangle(cornerRadius: 10)
                .stroke()
        }
        
    }
    
}

extension View {
    func playerNameBox(active: Bool) -> some View {
        modifier(PlayerNameBox(active: active))
    }
}

struct UIDesign_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Active")
                .playerNameBox(active: true)
            Text("Inactive")
                .playerNameBox(active: false)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray)
    }
}
