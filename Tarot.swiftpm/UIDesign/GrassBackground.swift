import SwiftUI

struct GrassBackground: View {
    
    let blockSize = CGSize(width: 60, height: 60)
    let greenDark = Color(#colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1))
    let greenAverage = Color(#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1))
    let greenLight = Color(#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1))
    
    var body: some View {
        GeometryReader { proxy in
            let blockCount: (width: Int, height: Int) = (
                max(1, Int(proxy.size.width / blockSize.width)),
                max(1, Int(proxy.size.height / blockSize.height)))
            LazyVGrid(columns: [GridItem](repeating: .init(), count: blockCount.width)) {
                ForEach(0 ..< blockCount.width * blockCount.height, id: \.self) { blockIndex in
                    GeometryReader { proxy in
                        VStack {
                            ForEach(0..<2) { i in
                                HStack {
                                    ForEach(0..<6) { i in
                                        Ellipse()
                                            .foregroundColor(greenLight.opacity(0.3))
                                            .scaleEffect(x: 0.6, y: 0.8)
                                            .offset(x: .random(in: -10...10),
                                                    y: .random(in: -20...10))
                                            .rotationEffect(Angle(degrees: .random(in: -20...20)))
                                            .blendMode(.plusLighter)
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(idealWidth: blockSize.width,
                        idealHeight: blockSize.height)
            }
        }
        .background {
            LinearGradient(colors: [greenAverage, greenDark],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
        }
        .clipShape(Rectangle())
    }
}

struct GrassBackground_Previews: PreviewProvider {
    static var previews: some View {
        GrassBackground()
            .border(.black)
            .padding()
    }
}
