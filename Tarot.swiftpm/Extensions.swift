import SwiftUI

extension String: LocalizedError {
    public var errorDescription: String? { self }
}

extension String {
    
    func firstLetters(n: Int) -> SubSequence {
        self[..<(index(startIndex, offsetBy: 2, limitedBy: endIndex) ?? endIndex)]
    }
    
}

extension Color: Codable {
    
    enum CodingKeys: String, CodingKey {
        case colorSpace
        case components
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let colorSpace = try container.decode(String.self, forKey: .colorSpace)
        let components = try container.decode([CGFloat].self, forKey: .components)
        
        guard let cgColorSpace = CGColorSpace(name: colorSpace as CFString),
              let cgColor = CGColor(colorSpace: cgColorSpace, components: components)
                else {
            throw CodingError.wrongData
        }
        
        self.init(cgColor: cgColor)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        guard let cgColor = self.cgColor,
              let colorSpace = cgColor.colorSpace?.name,
              let components = cgColor.components else {
            throw CodingError.wrongData
        }
        
        try container.encode(colorSpace as String, forKey: .colorSpace)
        try container.encode(components, forKey: .components)
    }
    
    enum CodingError: Error {
        case wrongColor
        case wrongData
    }
}

import CoreGraphics

extension CGPoint: AdditiveArithmetic {
    
    init(_ size: CGSize) {
        self.init(x: size.width, y: size.height)
    }
    
    public static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    public static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    public static func * (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
    }
    
    public static func / (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
    }
    
    public static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    
    public static func * (lhs: CGFloat, rhs: CGPoint) -> CGPoint {
        rhs * lhs
    }
    
    public static func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    
    public func squaredNorme() -> CGFloat {
        x * x + y * y
    }
    
    public static func lerp(_ a: CGPoint, _ b: CGPoint, _ t: CGFloat) -> CGPoint {
        return CGPoint(
            x: a.x + (b.x - a.x) * t,
            y: a.y + (b.y - a.y) * t
        )
    }
    
}

