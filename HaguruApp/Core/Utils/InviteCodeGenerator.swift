import Foundation

enum InviteCodeGenerator {
    private static let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"

    static func generate(prefix: String = "HAGURU") -> String {
        let suffix = String((0..<4).map { _ in chars.randomElement()! })
        return "\(prefix)-\(suffix)"
    }
}
