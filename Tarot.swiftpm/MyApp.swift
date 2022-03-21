import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

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
