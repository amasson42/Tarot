import SwiftUI

extension String: LocalizedError {
    public var errorDescription: String? { self }
}

extension String {
    
    func firstLetters(n: Int) -> SubSequence {
        self[..<(index(startIndex, offsetBy: 2, limitedBy: endIndex) ?? endIndex)]
    }
    
}
