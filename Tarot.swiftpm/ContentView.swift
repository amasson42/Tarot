import SwiftUI

extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}

struct PolygoneN: Shape {
    var angles = 3
    
    func path(in rect: CGRect) -> Path {
        guard angles > 0 else {
            return Path(ellipseIn: rect)
        }
//        return Path(ellipseIn: rect)
        let center = CGPoint(x: rect.midX,
                             y: rect.midY)
        var path = Path()
        path.move(to: center + CGPoint(x: rect.width / 2,
                                       y: 0))
        for angle in stride(from: 0, to: Double.pi * 2, by: Double.pi * 2 / Double(angles)) {
            let offseter = CGPoint(x: cos(Double(angle)) * rect.width / 2,
                                 y: sin(Double(angle)) * rect.height / 2)
            path.addLine(to: center + offseter)
        }
        path.closeSubpath()
        return path
    }
}

struct ContentView: View {
    @State private var angleCount = 3
    
    var body: some View {
        NavigationView {
            VStack {
                PolygoneN(angles: angleCount)
                    .fill(.red, style: FillStyle(eoFill: true, antialiased: true))
                Text("Le polygone")
                Slider(value: Binding(get: { 
                    Double(angleCount)
                }, set: {
                    angleCount = Int($0)
                }), in: 2...10)
                
                //                CountAppView()
            }
        }
    }
}

struct MenuView: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: Text("Play")) {
                    Text("Play")
                }
                NavigationLink(destination: CountAppView()) {
                    Text("Count")
                }
                NavigationLink(destination: Text("Assist")) {
                    Text("Assist")
                }
            }
            .navigationBarHidden(true)
        }
    }
}
