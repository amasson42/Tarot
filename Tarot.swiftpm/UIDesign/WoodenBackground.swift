import SwiftUI

struct WoodenBackground: View {
    
    let lightBrown = Color(#colorLiteral(red: 0.3450980484485626, green: 0.1999998688697815, blue: 3.609806498161561e-08, alpha: 1.0))
    let averageBrown = Color(#colorLiteral(red: 0.32787325978279114, green: 0.16395539045333862, blue: 9.024516245403902e-09, alpha: 1.0))
    let darkBrown = Color(#colorLiteral(red: 0.19334223866462708, green: 0.10131523758172989, blue: 9.024516245403902e-09, alpha: 1.0))
    
    var body: some View {
        LinearGradient(colors: [
            lightBrown,
            averageBrown,
            darkBrown
        ], startPoint: .leading, endPoint: .trailing)
    }
    
}

struct WoodenBackground_Previews: PreviewProvider {
    static var previews: some View {
        WoodenBackground()
            .border(.black)
            .padding()
    }
}
