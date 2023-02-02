
struct JetonsBoardPlayer {
    var name: String
    var jetonsCount: Int
}

extension JetonsBoardPlayer: ExpressibleByStringLiteral {
    init(stringLiteral value: StringLiteralType) {
        self.init(name: value, jetonsCount: 10)
    }
}
