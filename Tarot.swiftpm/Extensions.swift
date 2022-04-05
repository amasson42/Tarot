import SwiftUI

extension UserDefaults {
    class CountApp {
        private let ud: UserDefaults
        
        init(_ ud: UserDefaults) {
            self.ud = ud
        }
        
        var playerNames: [String]? {
            set { ud.set(newValue, forKey: "countApp_playerNames") }
            get { ud.stringArray(forKey: "countApp_playerNames") }
        }
    }
    
    var countApp: CountApp { CountApp(self) }
    
}

extension String: LocalizedError {
    public var errorDescription: String? { self }
}

extension String {
    
    func firstLetters(n: Int) -> SubSequence {
        self[..<(index(startIndex, offsetBy: 2, limitedBy: endIndex) ?? endIndex)]
    }
    
}
