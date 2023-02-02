import SwiftUI

struct JetonsBoardView: View {
    
    var exitClosure: (() -> ())?
    
    @State var players: [JetonsBoardPlayer] = ["A", "B", "C", "D", "E", "F", "G", "H"]
    
    func stackPosition(at p: CGFloat, in proxy: GeometryProxy) -> CGPoint {
        CGPoint(
            x: ((cos(.pi * p * 2)) + 1) * proxy.size.width / 2,
            y: ((sin(.pi * p * 2)) + 1) * proxy.size.height / 2)
    }
    
    func closestStackIndex(at location: CGPoint, in proxy: GeometryProxy) -> Int {
        
        let squaredDistances: [CGFloat] = players.indices
            .map {
                let p = CGFloat($0) / CGFloat(players.count)
                let position = stackPosition(at: p, in: proxy)
                return (position - location).squaredNorme()
            }
        
        return squaredDistances
            .enumerated()
            .min(by: {
                $0.element < $1.element
            })?.offset ?? 0
        
    }
    
    var body: some View {
        
        ZStack {
            
            GeometryReader { proxy in
                
                ForEach(players.indices, id: \.self) { pi in
                    let p = Float(pi) / Float(players.count)
                    let stackSize = min(min(proxy.size.width, proxy.size.height) / 4, 150)
                    let stackPosition = stackPosition(at: CGFloat(p), in: proxy)
                    
                    JetonsStackView(player: players[pi])
                        .frame(width: stackSize, height: stackSize)
                        .offset(x: 0, y: -stackSize / 2)
                        .rotationEffect(.degrees(360 * Double(p) + -90))
                        .position(x: stackPosition.x, y: stackPosition.y)
                        .gesture(
                            DragGesture()
                                .onChanged { v in
                                    let i = closestStackIndex(at: v.location, in: proxy)
                                    print("to \(v.location) = \(i)")
                                    
                                }
                        )
                }
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GrassBackground())
        
    }
}

struct JetonsStackView: View {
    var player: JetonsBoardPlayer
    @State private var arrowOffset: CGSize = .zero
    
    var body: some View {
        let dropDelegate = MainStackDropDelegate(offset: $arrowOffset)
        
        Color.red
            .onDrag {
                print("Player \(player.name)")
                return NSItemProvider()
            } preview: { 
                Color.green.frame(width: 40, height: 40)
            }
            .onDrop(of: ["jetons"], delegate: dropDelegate)
            .overlay {
                Rectangle()
                    .frame(width: 10, height: 10)
                    .offset(arrowOffset)
            }
    }
    
    struct MainStackDropDelegate: DropDelegate {
        @Binding var offset: CGSize
        
        func validateDrop(info: DropInfo) -> Bool {
            return true
//            return info.hasItemsConforming(to: ["jetons"])
        }
        
        func dropEntered(info: DropInfo) {
            offset = .init(width: 50, height: 50)
        }
        
        func performDrop(info: DropInfo) -> Bool {
            return true
        }
        
        func dropUpdated(info: DropInfo) -> DropProposal? {
            offset = CGSize(width: info.location.x,
                            height: info.location.y)
            return nil
        }
        
        func dropExited(info: DropInfo) {
            offset = .zero
        }
    }
}

struct JetonsBoardView_Previews: PreviewProvider {
    static var previews: some View {
        JetonsBoardView()
    }
}
